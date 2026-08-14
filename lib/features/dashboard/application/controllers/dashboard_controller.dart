import 'package:flutter/foundation.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  failure,
}

class DashboardController extends ChangeNotifier {
  DashboardController({
    required DashboardRepository repository,
  }) : _repository = repository;

  final DashboardRepository _repository;

  DashboardStatus _status =
      DashboardStatus.initial;

  DashboardSummary? _summary;

  String? _errorMessage;

  DashboardStatus get status => _status;

  DashboardSummary? get summary => _summary;

  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == DashboardStatus.loading;

  Future<void> loadDashboard() async {
    if (isLoading) {
      return;
    }

    _status = DashboardStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      _summary =
      await _repository.getDashboardSummary();

      _status = DashboardStatus.success;
    } catch (_) {
      _status = DashboardStatus.failure;

      _errorMessage =
      'Unable to load dashboard. Please try again.';
    }

    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}