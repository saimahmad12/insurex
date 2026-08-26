import '../entities/claim_payout.dart';
import '../entities/payout_method.dart';

abstract interface class ClaimPayoutRepository {
  Future<List<PayoutMethod>> getPayoutMethods();

  Future<PayoutMethod> addPayoutMethod(PayoutMethodRequest request);

  Future<PayoutMethod> verifyPayoutMethod(String payoutMethodId);

  Future<ClaimPayout> requestPayout({
    required String claimId,
    required String payoutMethodId,
    required String idempotencyKey,
  });

  Future<ClaimPayout?> getPayoutByClaimId(String claimId);

  Future<List<ClaimPayout>> getPayoutHistory();

  Future<ClaimPayout> refreshPayoutStatus(String payoutId);
}
