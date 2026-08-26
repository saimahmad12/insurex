import '../entities/insurance_claim.dart';

abstract interface class ClaimStatusRepository {
  Future<List<InsuranceClaim>> getClaims();

  Future<InsuranceClaim?> getClaimById(String claimId);

  Future<InsuranceClaim?> getMostRecentActiveClaim();
}
