import '../entities/insurance_policy.dart';

abstract interface class PoliciesRepository {
  Future<List<InsurancePolicy>> getPolicies();

  Future<void> addIssuedPolicy(InsurancePolicy policy);
}
