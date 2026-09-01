import '../../../policies/domain/entities/insurance_policy.dart';
import '../../../policies/domain/repositories/policies_repository.dart';
import '../../../profile/domain/entities/identity_verification.dart';
import '../../../profile/domain/repositories/identity_verification_repository.dart';
import '../../domain/entities/policy_application.dart';
import '../../domain/entities/policy_eligibility.dart';
import '../../domain/entities/policy_issuance.dart';
import '../../domain/entities/policy_purchase_draft.dart';
import '../../domain/entities/policy_quote.dart';
import '../../domain/entities/premium_payment.dart';
import '../../domain/repositories/policy_purchase_repository.dart';

class MockPolicyPurchaseRepository implements PolicyPurchaseRepository {
  MockPolicyPurchaseRepository({
    required IdentityVerificationRepository identityRepository,
    required PoliciesRepository policiesRepository,
    this.delay = const Duration(milliseconds: 300),
    this.failDraft = false,
    this.failEligibility = false,
    this.failQuote = false,
    this.failIssuance = false,
    this.forceEligibilityDecision,
    this.quoteValidity = const Duration(minutes: 15),
  }) : _identityRepository = identityRepository,
       _policiesRepository = policiesRepository;

  final IdentityVerificationRepository _identityRepository;
  final PoliciesRepository _policiesRepository;
  final Duration delay;
  final bool failDraft;
  final bool failEligibility;
  final bool failQuote;
  final bool failIssuance;
  final EligibilityDecision? forceEligibilityDecision;
  final Duration quoteValidity;
  final Map<String, PolicyPurchaseDraft> _drafts =
      <String, PolicyPurchaseDraft>{};
  int draftSaveCallCount = 0;
  int eligibilityCallCount = 0;
  int quoteCallCount = 0;
  int issuanceCallCount = 0;
  int _quoteSequence = 1;
  int _policySequence = 100;

  @override
  Future<PolicyPurchaseDraft?> getDraft(String productId) async {
    await _wait();
    if (failDraft) {
      throw StateError('Unable to load the policy draft.');
    }
    return _drafts[productId];
  }

  @override
  Future<void> saveDraft(PolicyPurchaseDraft draft) async {
    draftSaveCallCount++;
    await _wait();
    if (failDraft) {
      throw StateError('Unable to save the policy draft.');
    }
    _drafts[draft.productId] = draft;
  }

  @override
  Future<void> deleteDraft(String productId) async {
    await _wait();
    _drafts.remove(productId);
  }

  @override
  Future<PolicyEligibilityResult> checkEligibility(
    PolicyEligibilityRequest request,
  ) async {
    eligibilityCallCount++;
    await _wait();
    if (failEligibility) {
      throw StateError('Eligibility could not be checked.');
    }
    final EligibilityDecision? forced = forceEligibilityDecision;
    if (forced != null) {
      return PolicyEligibilityResult(
        decision: forced,
        reason: forced == EligibilityDecision.ineligible
            ? 'The selected product is not currently available for this application.'
            : null,
        requiredInformation:
            forced == EligibilityDecision.additionalInformationRequired
            ? const <String>['Complete required product information.']
            : const <String>[],
      );
    }
    if (!request.identityVerified) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.ineligible,
        reason: 'Identity verification is required before applying.',
      );
    }
    if (!request.productAvailable) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.ineligible,
        reason: 'This product is no longer available.',
      );
    }
    if (request.age < request.minimumAge || request.age > request.maximumAge) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.ineligible,
        reason: 'The provider age requirements are not met.',
      );
    }
    if (request.location.trim().isEmpty || !request.locationSupported) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.ineligible,
        reason: 'The application location is not supported.',
      );
    }
    if (request.hasRestrictedExistingPolicy) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.ineligible,
        reason: 'An existing-policy restriction applies to this product.',
      );
    }
    if (!request.hasRequiredInformation) {
      return const PolicyEligibilityResult(
        decision: EligibilityDecision.additionalInformationRequired,
        requiredInformation: <String>[
          'Complete the category-specific application.',
        ],
      );
    }
    return const PolicyEligibilityResult(
      decision: EligibilityDecision.eligible,
    );
  }

  @override
  Future<PolicyQuote> generateQuote(PolicyQuoteRequest request) async {
    quoteCallCount++;
    await _wait();
    if (failQuote || !request.product.isAvailable) {
      throw StateError('A final quote is unavailable.');
    }
    final double coverageFactor =
        request.configuration.coverageAmount / request.product.minimumCoverage;
    final double durationFactor = request.configuration.durationMonths / 12;
    final double peopleFactor =
        1 + (request.configuration.insuredPeople - 1) * 0.45;
    final double deductibleDiscount = request.configuration.deductible > 0
        ? request.product.startingPremium * 0.05
        : 0;
    final double addOnCost =
        request.configuration.addOns.length *
        request.product.startingPremium *
        0.08;
    final double basePremium =
        request.product.startingPremium *
        coverageFactor.clamp(1.0, 8.0).toDouble() *
        durationFactor *
        peopleFactor;
    final double taxes = basePremium * 0.05;
    const double fees = 500;
    final DateTime now = DateTime.now();
    return PolicyQuote(
      id: 'QUOTE-${(_quoteSequence++).toString().padLeft(5, '0')}',
      providerName: request.product.providerName,
      productName: request.product.name,
      configuration: request.configuration,
      basePremium: basePremium,
      taxes: taxes,
      fees: fees + addOnCost,
      discounts: deductibleDiscount,
      totalPremium: basePremium + taxes + fees + addOnCost - deductibleDiscount,
      effectiveDate: now.add(const Duration(days: 1)),
      expiresAt: now.add(quoteValidity),
    );
  }

  @override
  Future<PolicyIssuanceResult> issuePolicy(
    PolicyIssuanceRequest request,
  ) async {
    issuanceCallCount++;
    await _wait();
    if (failIssuance) {
      throw StateError('The provider could not issue the policy.');
    }
    final IdentityVerification identity = await _identityRepository
        .getIdentityVerification();
    if (identity.status != IdentityVerificationStatus.verified ||
        request.application.status != PolicyApplicationStatus.approved ||
        request.payment.status != PremiumPaymentStatus.paid ||
        request.quote.isExpiredAt(DateTime.now())) {
      throw StateError('Policy issuance requirements are not satisfied.');
    }
    final int sequence = _policySequence++;
    final DateTime startDate = request.quote.effectiveDate;
    final DateTime expiryDate = DateTime(
      startDate.year,
      startDate.month + request.quote.configuration.durationMonths,
      startDate.day,
    );
    final String documentReference = 'DOC-POL-$sequence';
    final InsurancePolicy policy = InsurancePolicy(
      id: 'issued-policy-$sequence',
      policyNumber: 'INS-${startDate.year}-$sequence',
      title: request.application.request.product.name,
      type: request.application.request.product.category,
      validTill: expiryDate,
      premium: request.quote.totalPremium,
      status: PolicyStatus.active,
      providerName: request.application.request.product.providerName,
      coverageAmount: request.quote.configuration.coverageAmount,
      startDate: startDate,
      paymentReference: request.payment.reference,
      documentReference: documentReference,
      blockchainRecordStatus: 'Pending Integration',
    );
    await _policiesRepository.addIssuedPolicy(policy);
    await deleteDraft(request.application.request.product.id);
    return PolicyIssuanceResult(
      policy: policy,
      policyDocumentReference: documentReference,
      blockchainRecordStatus: 'Pending Integration',
    );
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
