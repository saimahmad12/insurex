import '../entities/policy_eligibility.dart';
import '../entities/policy_issuance.dart';
import '../entities/policy_purchase_draft.dart';
import '../entities/policy_quote.dart';

abstract interface class PolicyPurchaseRepository {
  Future<PolicyPurchaseDraft?> getDraft(String productId);

  Future<void> saveDraft(PolicyPurchaseDraft draft);

  Future<void> deleteDraft(String productId);

  Future<PolicyEligibilityResult> checkEligibility(
    PolicyEligibilityRequest request,
  );

  Future<PolicyQuote> generateQuote(PolicyQuoteRequest request);

  Future<PolicyIssuanceResult> issuePolicy(PolicyIssuanceRequest request);
}
