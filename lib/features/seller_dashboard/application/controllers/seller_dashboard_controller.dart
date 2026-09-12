import 'package:flutter/foundation.dart';

import '../../domain/entities/seller_dashboard.dart';
import '../../domain/repositories/seller_dashboard_repository.dart';

enum SellerDashboardStatus {
  initial,
  loading,
  loaded,
  empty,
  failure,
  refreshing,
  accountUnavailable,
  accountNotApproved,
}

class SellerDashboardController extends ChangeNotifier {
  SellerDashboardController({
    required SellerDashboardRepository repository,
    required SellerDashboardAccount? account,
  }) : _repository = repository,
       _account = account,
       _status = account == null
           ? SellerDashboardStatus.accountUnavailable
           : account.isApproved
           ? SellerDashboardStatus.initial
           : SellerDashboardStatus.accountNotApproved;

  final SellerDashboardRepository _repository;
  final SellerDashboardAccount? _account;

  SellerDashboardStatus _status;
  SellerDashboard? _dashboard;
  String? _errorMessage;
  bool _requestInProgress = false;
  bool _isDisposed = false;

  SellerDashboardStatus get status => _status;
  SellerDashboardAccount? get account => _account;
  SellerDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _status == SellerDashboardStatus.refreshing;
  bool get isRequestInProgress => _requestInProgress;

  Future<void> loadDashboard() async {
    if (!_canRequest || _requestInProgress) {
      return;
    }

    _requestInProgress = true;
    _status = SellerDashboardStatus.loading;
    _dashboard = null;
    _errorMessage = null;
    _notifyListenersSafely();

    await _requestDashboard();
  }

  Future<void> refreshDashboard() async {
    if (!_canRequest || _requestInProgress) {
      return;
    }
    if (_dashboard == null) {
      return loadDashboard();
    }

    _requestInProgress = true;
    _status = SellerDashboardStatus.refreshing;
    _errorMessage = null;
    _notifyListenersSafely();

    await _requestDashboard();
  }

  bool get _canRequest =>
      !_isDisposed && _account != null && _account.isApproved;

  Future<void> _requestDashboard() async {
    try {
      final SellerDashboard result = await _repository.getDashboard(
        businessEmail: _account!.businessEmail,
      );
      if (_isDisposed) {
        return;
      }
      _dashboard = result;
      _status = result.isEmpty
          ? SellerDashboardStatus.empty
          : SellerDashboardStatus.loaded;
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      if (_dashboard == null) {
        _status = SellerDashboardStatus.failure;
        _errorMessage =
            'Unable to load the seller dashboard. Please try again.';
      } else {
        _status = _dashboard!.isEmpty
            ? SellerDashboardStatus.empty
            : SellerDashboardStatus.loaded;
        _errorMessage =
            'The dashboard could not be refreshed. Existing data is still shown.';
      }
    } finally {
      _requestInProgress = false;
      _notifyListenersSafely();
    }
  }

  void _notifyListenersSafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
