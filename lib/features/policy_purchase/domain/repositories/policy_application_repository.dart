import '../entities/policy_application.dart';

abstract interface class PolicyApplicationRepository {
  Future<PolicyApplication> submitApplication(
    PolicyApplicationSubmissionRequest request,
  );

  Future<PolicyApplication> refreshApplication(String applicationId);
}
