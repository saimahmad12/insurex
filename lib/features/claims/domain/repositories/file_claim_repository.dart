import '../entities/claim_policy.dart';
import '../entities/claim_request.dart';
import '../entities/claim_submission_result.dart';

abstract interface class FileClaimRepository {
  Future<List<ClaimPolicy>> loadPolicies();

  Future<ClaimSubmissionResult> submitClaim(ClaimRequest request);
}
