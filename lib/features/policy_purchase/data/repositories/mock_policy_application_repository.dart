import '../../domain/entities/policy_application.dart';
import '../../domain/repositories/policy_application_repository.dart';

class MockPolicyApplicationRepository implements PolicyApplicationRepository {
  MockPolicyApplicationRepository({
    this.delay = const Duration(milliseconds: 300),
    this.failSubmission = false,
    this.failReview = false,
    this.reviewOutcome = PolicyApplicationStatus.approved,
  });

  final Duration delay;
  final bool failSubmission;
  final bool failReview;
  final PolicyApplicationStatus reviewOutcome;
  final Map<String, PolicyApplication> _applications =
      <String, PolicyApplication>{};
  final Map<String, PolicyApplication> _applicationsByQuote =
      <String, PolicyApplication>{};
  int submissionCallCount = 0;
  int refreshCallCount = 0;
  int _sequence = 1;

  @override
  Future<PolicyApplication> submitApplication(
    PolicyApplicationSubmissionRequest request,
  ) async {
    submissionCallCount++;
    await _wait();
    if (failSubmission) {
      throw StateError('The policy application could not be submitted.');
    }
    final PolicyApplication? existing = _applicationsByQuote[request.quote.id];
    if (existing != null) {
      return existing;
    }
    final PolicyApplication application = PolicyApplication(
      id: 'APP-${(_sequence++).toString().padLeft(5, '0')}',
      request: request,
      status: request.product.requiresProviderReview
          ? PolicyApplicationStatus.underReview
          : PolicyApplicationStatus.approved,
      submittedAt: DateTime.now(),
    );
    _applications[application.id] = application;
    _applicationsByQuote[request.quote.id] = application;
    return application;
  }

  @override
  Future<PolicyApplication> refreshApplication(String applicationId) async {
    refreshCallCount++;
    await _wait();
    if (failReview) {
      throw StateError('Provider review could not be refreshed.');
    }
    final PolicyApplication? current = _applications[applicationId];
    if (current == null) {
      throw StateError('The policy application was not found.');
    }
    if (current.status != PolicyApplicationStatus.underReview &&
        current.status !=
            PolicyApplicationStatus.additionalInformationRequired) {
      return current;
    }
    final PolicyApplication updated = current.copyWith(
      status: reviewOutcome,
      generalReason: switch (reviewOutcome) {
        PolicyApplicationStatus.rejected =>
          'The provider could not approve this application.',
        PolicyApplicationStatus.additionalInformationRequired =>
          'The provider needs additional application information.',
        _ => null,
      },
    );
    _applications[applicationId] = updated;
    _applicationsByQuote[current.request.quote.id] = updated;
    return updated;
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
