import 'package:flutter/foundation.dart';

import '../../domain/entities/claim_payout.dart';
import '../../domain/entities/payout_filter.dart';
import '../../domain/repositories/claim_payout_repository.dart';

enum PaymentsHistoryLoadStatus { initial, loading, success, empty, failure }

enum PaymentsHistoryRefreshStatus { idle, refreshing, failure }

class PaymentsHistoryController extends ChangeNotifier {
  PaymentsHistoryController({required ClaimPayoutRepository repository})
    : _repository = repository;

  final ClaimPayoutRepository _repository;

  PaymentsHistoryLoadStatus _loadStatus = PaymentsHistoryLoadStatus.initial;
  PaymentsHistoryRefreshStatus _refreshStatus =
      PaymentsHistoryRefreshStatus.idle;
  List<ClaimPayout> _payouts = const <ClaimPayout>[];
  PayoutFilter _selectedFilter = PayoutFilter.all;
  String? _errorMessage;
  String? _refreshErrorMessage;
  bool _initialized = false;
  bool _requestInProgress = false;
  bool _disposed = false;

  PaymentsHistoryLoadStatus get loadStatus => _loadStatus;
  PaymentsHistoryRefreshStatus get refreshStatus => _refreshStatus;
  List<ClaimPayout> get payouts => _payouts;
  PayoutFilter get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;
  String? get refreshErrorMessage => _refreshErrorMessage;
  bool get isInitialLoading =>
      _loadStatus == PaymentsHistoryLoadStatus.loading && _payouts.isEmpty;
  bool get isRefreshing =>
      _refreshStatus == PaymentsHistoryRefreshStatus.refreshing;

  List<ClaimPayout> get visiblePayouts => List<ClaimPayout>.unmodifiable(
    _payouts.where(
      (ClaimPayout payout) => payout.status.matchesFilter(_selectedFilter),
    ),
  );

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadInitial();
  }

  Future<void> retry() => _loadInitial();

  void changeFilter(PayoutFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
    _notify();
  }

  Future<void> refresh() async {
    if (_requestInProgress) {
      return;
    }
    _requestInProgress = true;
    _refreshStatus = PaymentsHistoryRefreshStatus.refreshing;
    _refreshErrorMessage = null;
    _notify();

    try {
      _payouts = List<ClaimPayout>.unmodifiable(
        await _repository.getPayoutHistory(),
      );
      _loadStatus = _payouts.isEmpty
          ? PaymentsHistoryLoadStatus.empty
          : PaymentsHistoryLoadStatus.success;
      _refreshStatus = PaymentsHistoryRefreshStatus.idle;
    } catch (_) {
      _refreshStatus = PaymentsHistoryRefreshStatus.failure;
      _refreshErrorMessage =
          'Unable to refresh payments. Existing information is shown.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
  }

  Future<void> _loadInitial() async {
    if (_requestInProgress) {
      return;
    }
    _requestInProgress = true;
    _loadStatus = PaymentsHistoryLoadStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      _payouts = List<ClaimPayout>.unmodifiable(
        await _repository.getPayoutHistory(),
      );
      _loadStatus = _payouts.isEmpty
          ? PaymentsHistoryLoadStatus.empty
          : PaymentsHistoryLoadStatus.success;
    } catch (_) {
      _loadStatus = PaymentsHistoryLoadStatus.failure;
      _errorMessage = 'Unable to load payment history. Please try again.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
