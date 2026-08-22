import '../entities/insurance_policy.dart';
import '../entities/policy_details.dart';

abstract interface class PolicyDetailsRepository {
  Future<PolicyDetails> getPolicyDetails(
      InsurancePolicy policy,
      );
}