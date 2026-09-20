import 'package:flutter/foundation.dart';

import '../../domain/entities/insurance_policy.dart';
import '../../domain/entities/policy_details.dart';
import '../../domain/repositories/policy_details_repository.dart';

enum PolicyDetailsStatus { initial, loading, success, failure }

class PolicyDetailsController extends ChangeNotifier {
  PolicyDetailsController({required PolicyDetailsRepository repository})
    : _repository = repository;

  final PolicyDetailsRepository _repository;

  PolicyDetailsStatus _status = PolicyDetailsStatus.initial;

  PolicyDetails? _details;

  String? _errorMessage;

  PolicyDetailsStatus get status => _status;

  PolicyDetails? get details => _details;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == PolicyDetailsStatus.loading;

  Future<void> loadPolicyDetails(InsurancePolicy policy) async {
    if (isLoading) {
      return;
    }

    _status = PolicyDetailsStatus.loading;
    _errorMessage = null;

    _notify();

    try {
      _details = await _repository.getPolicyDetails(policy);

      _status = PolicyDetailsStatus.success;
    } catch (_) {
      _status = PolicyDetailsStatus.failure;

      _errorMessage = 'Unable to load policy details. Please try again.';
    }

    _notify();
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
