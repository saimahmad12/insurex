import 'package:flutter/foundation.dart';

import '../../domain/entities/policy_application.dart';
import '../../domain/repositories/policy_application_repository.dart';

enum PolicyApplicationOperationStatus { idle, submitting, refreshing, failure }

class PolicyApplicationController extends ChangeNotifier {
  PolicyApplicationController({required PolicyApplicationRepository repository})
    : _repository = repository;

  final PolicyApplicationRepository _repository;
  PolicyApplicationOperationStatus operationStatus =
      PolicyApplicationOperationStatus.idle;
  PolicyApplication? application;
  bool informationAccurate = false;
  bool coverageReviewed = false;
  bool processingConsent = false;
  String? errorMessage;

  bool get declarationsAccepted =>
      informationAccurate && coverageReviewed && processingConsent;

  void updateDeclarations({
    bool? informationAccurate,
    bool? coverageReviewed,
    bool? processingConsent,
  }) {
    this.informationAccurate = informationAccurate ?? this.informationAccurate;
    this.coverageReviewed = coverageReviewed ?? this.coverageReviewed;
    this.processingConsent = processingConsent ?? this.processingConsent;
    _notify();
  }

  Future<PolicyApplication?> submit(
    PolicyApplicationSubmissionRequest request,
  ) async {
    if (!declarationsAccepted ||
        operationStatus == PolicyApplicationOperationStatus.submitting ||
        application != null) {
      return application;
    }
    operationStatus = PolicyApplicationOperationStatus.submitting;
    errorMessage = null;
    _notify();
    try {
      application = await _repository.submitApplication(request);
      operationStatus = PolicyApplicationOperationStatus.idle;
    } catch (_) {
      operationStatus = PolicyApplicationOperationStatus.failure;
      errorMessage = 'The policy application could not be submitted.';
    }
    _notify();
    return application;
  }

  Future<PolicyApplication?> refreshReview() async {
    final PolicyApplication? current = application;
    if (current == null ||
        operationStatus == PolicyApplicationOperationStatus.refreshing) {
      return current;
    }
    operationStatus = PolicyApplicationOperationStatus.refreshing;
    errorMessage = null;
    _notify();
    try {
      application = await _repository.refreshApplication(current.id);
      operationStatus = PolicyApplicationOperationStatus.idle;
    } catch (_) {
      operationStatus = PolicyApplicationOperationStatus.failure;
      errorMessage = 'Provider review could not be refreshed.';
    }
    _notify();
    return application;
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
