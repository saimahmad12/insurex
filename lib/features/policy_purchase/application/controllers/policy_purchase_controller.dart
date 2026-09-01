import 'package:flutter/foundation.dart';

import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import '../../../insurance_marketplace/domain/repositories/insurance_marketplace_repository.dart';
import '../../../profile/domain/entities/identity_verification.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/beneficiary.dart';
import '../../domain/entities/policy_application_details.dart';
import '../../domain/entities/policy_configuration.dart';
import '../../domain/entities/policy_eligibility.dart';
import '../../domain/entities/policy_application.dart';
import '../../domain/entities/policy_issuance.dart';
import '../../domain/entities/policy_purchase_draft.dart';
import '../../domain/entities/policy_quote.dart';
import '../../domain/entities/premium_payment.dart';
import '../../domain/repositories/policy_purchase_repository.dart';
import '../validators/beneficiary_validator.dart';
import '../validators/policy_purchase_validator.dart';

enum PolicyPurchaseLoadStatus { initial, loading, success, failure }

enum DraftSaveStatus { idle, saving, saved, failure }

enum EligibilityCheckStatus { idle, checking, complete, failure }

enum PolicyIssuanceStatus { idle, issuing, issued, failure }

enum PolicyPurchaseIdentityAction {
  startVerification,
  resumeVerification,
  verificationPending,
  continuePurchase,
}

enum PolicyPurchaseStep {
  configure,
  application,
  beneficiaries,
  quote,
  review,
  providerReview,
  payment,
  issuing,
  success,
}

class PolicyPurchaseController extends ChangeNotifier {
  PolicyPurchaseController({
    required InsuranceMarketplaceRepository marketplaceRepository,
    required ProfileRepository profileRepository,
    required PolicyPurchaseRepository purchaseRepository,
    required this.productId,
  }) : _marketplaceRepository = marketplaceRepository,
       _profileRepository = profileRepository,
       _purchaseRepository = purchaseRepository;

  final InsuranceMarketplaceRepository _marketplaceRepository;
  final ProfileRepository _profileRepository;
  final PolicyPurchaseRepository _purchaseRepository;
  final String productId;

  PolicyPurchaseLoadStatus loadStatus = PolicyPurchaseLoadStatus.initial;
  DraftSaveStatus draftSaveStatus = DraftSaveStatus.idle;
  EligibilityCheckStatus eligibilityStatus = EligibilityCheckStatus.idle;
  PolicyIssuanceStatus issuanceStatus = PolicyIssuanceStatus.idle;
  PolicyPurchaseStep step = PolicyPurchaseStep.configure;
  InsuranceProduct? product;
  UserProfile? profile;
  PolicyConfiguration? configuration;
  PolicyApplicationDetails? applicationDetails;
  List<PolicyBeneficiary> beneficiaries = const <PolicyBeneficiary>[];
  PolicyEligibilityResult? eligibility;
  PolicyIssuanceResult? issuanceResult;
  Map<String, String> validationErrors = const <String, String>{};
  String? errorMessage;
  String? draftMessage;
  bool _initialized = false;

  IdentityVerificationStatus get identityStatus =>
      profile?.identityVerification.status ??
      IdentityVerificationStatus.notStarted;

  bool get isIdentityVerified =>
      identityStatus == IdentityVerificationStatus.verified;

  PolicyPurchaseIdentityAction get identityAction => switch (identityStatus) {
    IdentityVerificationStatus.notStarted ||
    IdentityVerificationStatus.rejected ||
    IdentityVerificationStatus.expired =>
      PolicyPurchaseIdentityAction.startVerification,
    IdentityVerificationStatus.capturing ||
    IdentityVerificationStatus.additionalCaptureRequired ||
    IdentityVerificationStatus.technicalFailure =>
      PolicyPurchaseIdentityAction.resumeVerification,
    IdentityVerificationStatus.submitted ||
    IdentityVerificationStatus.pending =>
      PolicyPurchaseIdentityAction.verificationPending,
    IdentityVerificationStatus.verified =>
      PolicyPurchaseIdentityAction.continuePurchase,
  };

  bool get isInitialLoading =>
      loadStatus == PolicyPurchaseLoadStatus.loading && product == null;

  Future<void> initialize() async {
    if (_initialized || loadStatus == PolicyPurchaseLoadStatus.loading) return;
    _initialized = true;
    loadStatus = PolicyPurchaseLoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final (
        InsuranceProduct loadedProduct,
        UserProfile? loadedProfile,
      ) = await (
        _marketplaceRepository
            .getProductById(productId)
            .then(
              (InsuranceProduct? value) =>
                  value ??
                  (throw StateError('The insurance product was not found.')),
            ),
        _profileRepository.getProfile(),
      ).wait;
      product = loadedProduct;
      profile = loadedProfile;
      final PolicyPurchaseDraft? draft = await _purchaseRepository.getDraft(
        productId,
      );
      configuration =
          draft?.configuration ?? _defaultConfiguration(loadedProduct);
      applicationDetails = draft?.applicationDetails;
      beneficiaries = draft?.beneficiaries ?? const <PolicyBeneficiary>[];
      loadStatus = PolicyPurchaseLoadStatus.success;
    } catch (_) {
      loadStatus = PolicyPurchaseLoadStatus.failure;
      errorMessage = 'The policy purchase could not be loaded.';
    }
    notifyListeners();
  }

  Future<void> retry() async {
    _initialized = false;
    await initialize();
  }

  Future<void> refreshProfile() async {
    final UserProfile? refreshed = await _profileRepository.refreshProfile();
    if (refreshed != null) {
      profile = refreshed;
      notifyListeners();
    }
  }

  void updateConfiguration(PolicyConfiguration value) {
    configuration = value;
    validationErrors = const <String, String>{};
    draftSaveStatus = DraftSaveStatus.idle;
    notifyListeners();
  }

  void goTo(PolicyPurchaseStep value) {
    step = value;
    notifyListeners();
  }

  void updateApplicationDetails(PolicyApplicationDetails value) {
    applicationDetails = value;
    validationErrors = const <String, String>{};
    draftSaveStatus = DraftSaveStatus.idle;
    notifyListeners();
  }

  void updateBeneficiaries(List<PolicyBeneficiary> value) {
    beneficiaries = List<PolicyBeneficiary>.unmodifiable(value);
    validationErrors = const <String, String>{};
    draftSaveStatus = DraftSaveStatus.idle;
    notifyListeners();
  }

  bool validateConfiguration() {
    final InsuranceProduct? currentProduct = product;
    final PolicyConfiguration? current = configuration;
    if (currentProduct == null || current == null) return false;
    validationErrors = PolicyPurchaseValidator.validateConfiguration(
      current,
      minimumCoverage: currentProduct.minimumCoverage,
      maximumCoverage: currentProduct.maximumCoverage,
    );
    notifyListeners();
    return validationErrors.isEmpty;
  }

  bool validateApplication() {
    final PolicyApplicationDetails? current = applicationDetails;
    if (current == null) {
      validationErrors = const <String, String>{
        'application': 'Complete the required application information.',
      };
    } else {
      validationErrors = PolicyPurchaseValidator.validateApplication(current);
    }
    notifyListeners();
    return validationErrors.isEmpty;
  }

  bool validateBeneficiaries() {
    if (product?.requiresBeneficiaries != true) return true;
    validationErrors = BeneficiaryValidator.validate(beneficiaries);
    notifyListeners();
    return validationErrors.isEmpty;
  }

  Future<bool> saveDraft() async {
    final PolicyConfiguration? current = configuration;
    if (current == null || draftSaveStatus == DraftSaveStatus.saving) {
      return false;
    }
    draftSaveStatus = DraftSaveStatus.saving;
    draftMessage = null;
    notifyListeners();
    try {
      await _purchaseRepository.saveDraft(
        PolicyPurchaseDraft(
          id: 'draft-$productId',
          productId: productId,
          configuration: current,
          applicationDetails: applicationDetails,
          beneficiaries: beneficiaries,
          updatedAt: DateTime.now(),
        ),
      );
      draftSaveStatus = DraftSaveStatus.saved;
      draftMessage = 'Draft saved';
      notifyListeners();
      return true;
    } catch (_) {
      draftSaveStatus = DraftSaveStatus.failure;
      draftMessage = 'Draft could not be saved.';
      notifyListeners();
      return false;
    }
  }

  Future<PolicyEligibilityResult?> checkEligibility() async {
    if (eligibilityStatus == EligibilityCheckStatus.checking) return null;
    final InsuranceProduct? currentProduct = product;
    final UserProfile? currentProfile = profile;
    if (currentProduct == null || currentProfile == null) return null;
    eligibilityStatus = EligibilityCheckStatus.checking;
    eligibility = null;
    notifyListeners();
    try {
      final DateTime today = DateTime.now();
      int age = today.year - currentProfile.dateOfBirth.year;
      if (DateTime(
        today.year,
        currentProfile.dateOfBirth.month,
        currentProfile.dateOfBirth.day,
      ).isAfter(today)) {
        age--;
      }
      final String city = currentProfile.address.city;
      eligibility = await _purchaseRepository.checkEligibility(
        PolicyEligibilityRequest(
          productId: productId,
          identityVerified: isIdentityVerified,
          age: age,
          minimumAge: currentProduct.minimumAge,
          maximumAge: currentProduct.maximumAge,
          location: city,
          locationSupported: currentProduct.supportedLocations.any(
            (String value) => value.toLowerCase() == city.toLowerCase(),
          ),
          productAvailable: currentProduct.isAvailable,
          hasRestrictedExistingPolicy: false,
          hasRequiredInformation: applicationDetails != null,
        ),
      );
      eligibilityStatus = EligibilityCheckStatus.complete;
    } catch (_) {
      eligibilityStatus = EligibilityCheckStatus.failure;
      errorMessage = 'Eligibility could not be checked.';
    }
    notifyListeners();
    return eligibility;
  }

  Future<void> deleteDraft() async {
    await _purchaseRepository.deleteDraft(productId);
  }

  Future<PolicyIssuanceResult?> issuePolicy({
    required PolicyApplication application,
    required PremiumPayment payment,
    required PolicyQuote quote,
  }) async {
    if (issuanceStatus == PolicyIssuanceStatus.issuing) return null;
    issuanceStatus = PolicyIssuanceStatus.issuing;
    step = PolicyPurchaseStep.issuing;
    errorMessage = null;
    notifyListeners();
    try {
      issuanceResult = await _purchaseRepository.issuePolicy(
        PolicyIssuanceRequest(
          application: application,
          payment: payment,
          quote: quote,
        ),
      );
      issuanceStatus = PolicyIssuanceStatus.issued;
      step = PolicyPurchaseStep.success;
    } catch (_) {
      issuanceStatus = PolicyIssuanceStatus.failure;
      errorMessage =
          'Policy issuance could not be completed. Payment is preserved.';
    }
    notifyListeners();
    return issuanceResult;
  }

  static PolicyConfiguration _defaultConfiguration(InsuranceProduct product) {
    return PolicyConfiguration(
      productId: product.id,
      coverageAmount: product.minimumCoverage,
      durationMonths: product.availableDurationsMonths.first,
      deductible: product.availableDeductibles.first,
      addOns: const <String>[],
      paymentFrequency: product.paymentFrequencies.first,
      insuredPeople: 1,
    );
  }
}
