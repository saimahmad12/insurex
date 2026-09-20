import 'package:flutter/foundation.dart';

import '../../domain/entities/insurance_policy.dart';
import '../../domain/repositories/policies_repository.dart';

enum PoliciesStatus { initial, loading, success, failure }

enum PolicyFilter { active, expired, all }

class PoliciesController extends ChangeNotifier {
  PoliciesController({required PoliciesRepository repository})
    : _repository = repository;

  final PoliciesRepository _repository;

  PoliciesStatus _status = PoliciesStatus.initial;

  List<InsurancePolicy> _policies = <InsurancePolicy>[];

  PolicyFilter _selectedFilter = PolicyFilter.active;

  String? _errorMessage;
  bool _initialized = false;
  bool _loadInProgress = false;

  PoliciesStatus get status => _status;

  PolicyFilter get selectedFilter => _selectedFilter;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == PoliciesStatus.loading;

  List<InsurancePolicy> get policies => _policies;

  List<InsurancePolicy> get filteredPolicies {
    switch (_selectedFilter) {
      case PolicyFilter.active:
        return _policies
            .where(
              (InsurancePolicy policy) => policy.status == PolicyStatus.active,
            )
            .toList();

      case PolicyFilter.expired:
        return _policies
            .where(
              (InsurancePolicy policy) => policy.status == PolicyStatus.expired,
            )
            .toList();

      case PolicyFilter.all:
        return _policies;
    }
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await loadPolicies();
  }

  Future<void> loadPolicies() async {
    if (_loadInProgress) {
      return;
    }

    _loadInProgress = true;
    _status = PoliciesStatus.loading;
    _errorMessage = null;

    _notify();

    try {
      _policies = await _repository.getPolicies();

      _status = PoliciesStatus.success;
    } catch (_) {
      _status = PoliciesStatus.failure;
      _errorMessage = 'Unable to load your policies. Please try again.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  void changeFilter(PolicyFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;
    _notify();
  }

  Future<void> refresh() async {
    await loadPolicies();
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
