import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'package:insurancex/features/insurance_marketplace/domain/entities/insurance_product.dart';
import 'package:insurancex/features/policies/data/repositories/mock_policies_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_purchase_controller.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_quote_controller.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/premium_payment_controller.dart';
import 'package:insurancex/features/policy_purchase/application/validators/beneficiary_validator.dart';
import 'package:insurancex/features/policy_purchase/application/validators/policy_purchase_validator.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_policy_application_repository.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_policy_purchase_repository.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_premium_payment_repository.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/beneficiary.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_application.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_application_details.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_configuration.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_eligibility.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_issuance.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_purchase_draft.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_quote.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/premium_payment.dart';

void main() {
  group('Policy purchase validation', () {
    test('validates every category using focused models', () {
      final DateTime now = DateTime.now();
      final List<PolicyApplicationDetails> valid = <PolicyApplicationDetails>[
        VehiclePolicyApplication(
          registrationNumber: 'SYN-001',
          make: 'Synthetic',
          model: 'Test',
          manufacturingYear: now.year,
          vehicleValue: 1000000,
          chassisNumber: 'SYNTHETIC-CHASSIS',
          usageType: 'Personal',
          existingDamageDeclaration: 'No existing damage declared',
        ),
        HealthPolicyApplication(
          members: <HealthInsuredMember>[
            HealthInsuredMember(
              legalName: 'Synthetic Member',
              relationship: 'Self',
              dateOfBirth: DateTime(1990),
            ),
          ],
          coverageRequirements: 'Hospital care',
          healthDeclaration: 'Synthetic declaration',
        ),
        TravelPolicyApplication(
          destination: 'Synthetic Destination',
          departureDate: now.add(const Duration(days: 10)),
          returnDate: now.add(const Duration(days: 20)),
          travellers: <TravelTraveller>[
            TravelTraveller(
              legalName: 'Synthetic Traveller',
              dateOfBirth: DateTime(1990),
            ),
          ],
          tripPurpose: 'Tourism',
          coverageRegion: 'Worldwide',
        ),
        const LifePolicyApplication(
          coverageAmount: 5000000,
          occupation: 'Engineer',
        ),
        const PropertyPolicyApplication(
          propertyType: 'House',
          address: 'Synthetic Address',
          estimatedValue: 10000000,
          ownershipStatus: 'Owned',
          coverageType: 'Building and contents',
        ),
      ];
      for (final PolicyApplicationDetails details in valid) {
        expect(PolicyPurchaseValidator.validateApplication(details), isEmpty);
      }
    });

    test('beneficiary allocation must total exactly one hundred', () {
      final List<PolicyBeneficiary> beneficiaries = <PolicyBeneficiary>[
        PolicyBeneficiary(
          legalName: 'Synthetic Nominee A',
          relationship: 'Family',
          dateOfBirth: DateTime(1990),
          contactDetails: 'masked-contact-a',
          allocationPercentage: 50,
        ),
        PolicyBeneficiary(
          legalName: 'Synthetic Nominee B',
          relationship: 'Family',
          dateOfBirth: DateTime(1992),
          contactDetails: 'masked-contact-b',
          allocationPercentage: 50,
        ),
      ];
      expect(BeneficiaryValidator.validate(beneficiaries), isEmpty);
      expect(
        BeneficiaryValidator.validate(<PolicyBeneficiary>[beneficiaries.first]),
        contains('allocation'),
      );
    });
  });

  group('Policy purchase repositories', () {
    late MockProfileRepository profileRepository;
    late MockPoliciesRepository policiesRepository;
    late MockPolicyPurchaseRepository repository;
    late InsuranceProduct product;
    late PolicyConfiguration configuration;

    setUp(() async {
      profileRepository = MockProfileRepository(delay: Duration.zero);
      policiesRepository = MockPoliciesRepository(delay: Duration.zero);
      repository = MockPolicyPurchaseRepository(
        identityRepository: profileRepository,
        policiesRepository: policiesRepository,
        delay: Duration.zero,
      );
      product = (await MockInsuranceMarketplaceRepository(
        delay: Duration.zero,
      ).getProductById('travel-worldwide-01'))!;
      configuration = PolicyConfiguration(
        productId: product.id,
        coverageAmount: product.minimumCoverage,
        durationMonths: product.availableDurationsMonths.first,
        deductible: product.availableDeductibles.first,
        addOns: const <String>[],
        paymentFrequency: product.paymentFrequencies.first,
        insuredPeople: 1,
      );
    });

    test('invalidating an in-flight quote discards its result', () async {
      final controller = PolicyQuoteController(repository: repository);
      final pending = controller.generate(
        product: product,
        configuration: configuration,
      );
      controller.invalidate();
      expect(await pending, isNull);
      expect(controller.quote, isNull);
      expect(controller.status, PolicyQuoteStatus.idle);
      controller.dispose();
    });

    test('failed quote regeneration cannot reuse an earlier quote', () async {
      final failing = MockPolicyPurchaseRepository(
        identityRepository: profileRepository,
        policiesRepository: policiesRepository,
        delay: Duration.zero,
        failQuote: true,
      );
      final controller = PolicyQuoteController(repository: failing);
      controller.quote = await repository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      expect(
        await controller.generate(
          product: product,
          configuration: configuration,
        ),
        isNull,
      );
      expect(controller.ensureCurrent(), isFalse);
      controller.dispose();
    });

    test('coverage and deductible reject non-finite amounts', () {
      for (final amount in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final errors = PolicyPurchaseValidator.validateConfiguration(
          configuration.copyWith(coverageAmount: amount, deductible: amount),
          minimumCoverage: product.minimumCoverage,
          maximumCoverage: product.maximumCoverage,
        );
        expect(errors, contains('coverageAmount'));
        expect(errors, contains('deductible'));
      }
    });
    test('saves, resumes, and deletes a draft', () async {
      final PolicyPurchaseDraft draft = PolicyPurchaseDraft(
        id: 'draft-synthetic',
        productId: product.id,
        configuration: configuration,
        updatedAt: DateTime.now(),
      );
      await repository.saveDraft(draft);
      expect(await repository.getDraft(product.id), same(draft));
      await repository.deleteDraft(product.id);
      expect(await repository.getDraft(product.id), isNull);
    });

    test('maps every identity status to the required purchase gate', () async {
      final Map<IdentityVerificationStatus, PolicyPurchaseIdentityAction>
      expected = <IdentityVerificationStatus, PolicyPurchaseIdentityAction>{
        IdentityVerificationStatus.notStarted:
            PolicyPurchaseIdentityAction.startVerification,
        IdentityVerificationStatus.capturing:
            PolicyPurchaseIdentityAction.resumeVerification,
        IdentityVerificationStatus.submitted:
            PolicyPurchaseIdentityAction.verificationPending,
        IdentityVerificationStatus.pending:
            PolicyPurchaseIdentityAction.verificationPending,
        IdentityVerificationStatus.verified:
            PolicyPurchaseIdentityAction.continuePurchase,
        IdentityVerificationStatus.rejected:
            PolicyPurchaseIdentityAction.startVerification,
        IdentityVerificationStatus.expired:
            PolicyPurchaseIdentityAction.startVerification,
        IdentityVerificationStatus.additionalCaptureRequired:
            PolicyPurchaseIdentityAction.resumeVerification,
        IdentityVerificationStatus.technicalFailure:
            PolicyPurchaseIdentityAction.resumeVerification,
      };

      for (final MapEntry<
            IdentityVerificationStatus,
            PolicyPurchaseIdentityAction
          >
          entry
          in expected.entries) {
        final MockProfileRepository source = MockProfileRepository(
          delay: Duration.zero,
        );
        final UserProfile base = (await source.getProfile())!;
        final MockProfileRepository statusProfile = MockProfileRepository(
          delay: Duration.zero,
          initialProfile: base.copyWith(
            identityVerification: IdentityVerification(
              status: entry.key,
              maskedIdentityNumber: '*****-*******-*',
            ),
          ),
        );
        final MockPolicyPurchaseRepository statusPurchase =
            MockPolicyPurchaseRepository(
              identityRepository: statusProfile,
              policiesRepository: MockPoliciesRepository(delay: Duration.zero),
              delay: Duration.zero,
            );
        final PolicyPurchaseController controller = PolicyPurchaseController(
          marketplaceRepository: MockInsuranceMarketplaceRepository(
            delay: Duration.zero,
          ),
          profileRepository: statusProfile,
          purchaseRepository: statusPurchase,
          productId: product.id,
        );
        await controller.initialize();
        expect(controller.identityAction, entry.value, reason: entry.key.name);
      }
    });

    test('coverage updates never reactivate initial loading', () async {
      final PolicyPurchaseController controller = PolicyPurchaseController(
        marketplaceRepository: MockInsuranceMarketplaceRepository(
          delay: Duration.zero,
        ),
        profileRepository: profileRepository,
        purchaseRepository: repository,
        productId: product.id,
      );
      await controller.initialize();
      final PolicyConfiguration changed = controller.configuration!.copyWith(
        coverageAmount: product.minimumCoverage * 2,
        durationMonths: 12,
        deductible: 10000,
        addOns: const <String>['Emergency assistance'],
        paymentFrequency: PremiumFrequency.quarterly,
        insuredPeople: 2,
      );
      controller.updateConfiguration(changed);

      expect(controller.configuration, same(changed));
      expect(controller.loadStatus, PolicyPurchaseLoadStatus.success);
      expect(controller.isInitialLoading, isFalse);
    });

    test('quote failure preserves selected coverage', () async {
      final MockPolicyPurchaseRepository failingQuoteRepository =
          MockPolicyPurchaseRepository(
            identityRepository: profileRepository,
            policiesRepository: policiesRepository,
            delay: Duration.zero,
            failQuote: true,
          );
      final PolicyPurchaseController purchaseController =
          PolicyPurchaseController(
            marketplaceRepository: MockInsuranceMarketplaceRepository(
              delay: Duration.zero,
            ),
            profileRepository: profileRepository,
            purchaseRepository: failingQuoteRepository,
            productId: product.id,
          );
      await purchaseController.initialize();
      final PolicyConfiguration selected = purchaseController.configuration!
          .copyWith(coverageAmount: product.minimumCoverage * 2);
      purchaseController.updateConfiguration(selected);
      final PolicyQuoteController quoteController = PolicyQuoteController(
        repository: failingQuoteRepository,
      );

      final Future<PolicyQuote?> operation = quoteController.generate(
        product: product,
        configuration: selected,
      );
      expect(quoteController.status, PolicyQuoteStatus.calculating);
      expect(await operation, isNull);
      expect(quoteController.status, PolicyQuoteStatus.unavailable);
      expect(purchaseController.configuration, same(selected));
      expect(purchaseController.isInitialLoading, isFalse);
    });

    test('premium payment supports only bank transfer and mobile wallets', () {
      expect(PremiumPaymentMethod.values, <PremiumPaymentMethod>[
        PremiumPaymentMethod.bankTransfer,
        PremiumPaymentMethod.easypaisa,
        PremiumPaymentMethod.jazzCash,
      ]);
      final PremiumPaymentController controller = PremiumPaymentController(
        repository: MockPremiumPaymentRepository(delay: Duration.zero),
      );
      expect(controller.selectedMethod, PremiumPaymentMethod.bankTransfer);
    });

    test(
      'checks identity, age, location, availability and information',
      () async {
        const PolicyEligibilityRequest eligible = PolicyEligibilityRequest(
          productId: 'synthetic-product',
          identityVerified: true,
          age: 30,
          minimumAge: 18,
          maximumAge: 70,
          location: 'Islamabad',
          locationSupported: true,
          productAvailable: true,
          hasRestrictedExistingPolicy: false,
          hasRequiredInformation: true,
        );
        expect(
          (await repository.checkEligibility(eligible)).decision,
          EligibilityDecision.eligible,
        );
        expect(
          (await repository.checkEligibility(
            const PolicyEligibilityRequest(
              productId: 'synthetic-product',
              identityVerified: false,
              age: 30,
              minimumAge: 18,
              maximumAge: 70,
              location: 'Islamabad',
              locationSupported: true,
              productAvailable: true,
              hasRestrictedExistingPolicy: false,
              hasRequiredInformation: true,
            ),
          )).decision,
          EligibilityDecision.ineligible,
        );
      },
    );

    test('generates final quote and detects expiry', () async {
      final PolicyQuote quote = await repository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      expect(quote.totalPremium, greaterThan(quote.basePremium));
      expect(quote.id, startsWith('QUOTE-'));
      expect(quote.isExpiredAt(quote.expiresAt), isTrue);
    });

    test('application and payment requests are idempotent', () async {
      final PolicyQuote quote = await repository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      final PolicyApplicationSubmissionRequest request = _applicationRequest(
        product,
        configuration,
        quote,
      );
      final MockPolicyApplicationRepository applications =
          MockPolicyApplicationRepository(delay: Duration.zero);
      final PolicyApplication first = await applications.submitApplication(
        request,
      );
      final PolicyApplication duplicate = await applications.submitApplication(
        request,
      );
      expect(duplicate.id, first.id);

      final MockPremiumPaymentRepository payments =
          MockPremiumPaymentRepository(delay: Duration.zero);
      final PremiumPayment payment = await payments.payPremium(
        applicationId: first.id,
        quoteId: quote.id,
        amount: quote.totalPremium,
        method: PremiumPaymentMethod.bankTransfer,
        idempotencyKey: 'synthetic-idempotency-key',
      );
      final PremiumPayment paymentDuplicate = await payments.payPremium(
        applicationId: first.id,
        quoteId: quote.id,
        amount: quote.totalPremium,
        method: PremiumPaymentMethod.bankTransfer,
        idempotencyKey: 'synthetic-idempotency-key',
      );
      expect(paymentDuplicate.id, payment.id);
    });

    test(
      'issues only after approval and payment, then syncs My Policies',
      () async {
        final PolicyQuote quote = await repository.generateQuote(
          PolicyQuoteRequest(product: product, configuration: configuration),
        );
        final PolicyApplication application =
            await MockPolicyApplicationRepository(
              delay: Duration.zero,
            ).submitApplication(
              _applicationRequest(product, configuration, quote),
            );
        final PremiumPayment payment =
            await MockPremiumPaymentRepository(delay: Duration.zero).payPremium(
              applicationId: application.id,
              quoteId: quote.id,
              amount: quote.totalPremium,
              method: PremiumPaymentMethod.bankTransfer,
              idempotencyKey: 'synthetic-issuance-key',
            );

        final PolicyIssuanceResult issuance = await repository.issuePolicy(
          PolicyIssuanceRequest(
            application: application,
            quote: quote,
            payment: payment,
          ),
        );
        final policies = await policiesRepository.getPolicies();
        expect(
          policies.any((policy) => policy.id == issuance.policy.id),
          isTrue,
        );
        expect(issuance.policy.paymentReference, payment.reference);
        expect(issuance.policy.documentReference, isNotEmpty);
      },
    );

    test('issuance rejects unverified identity and failed payment', () async {
      final UserProfile verifiedProfile = (await profileRepository
          .getProfile())!;
      final MockProfileRepository unverifiedProfile = MockProfileRepository(
        delay: Duration.zero,
        initialProfile: verifiedProfile.copyWith(
          identityVerification: const IdentityVerification(
            status: IdentityVerificationStatus.notStarted,
            maskedIdentityNumber: '*****-*******-*',
          ),
        ),
      );
      final MockPolicyPurchaseRepository guardedRepository =
          MockPolicyPurchaseRepository(
            identityRepository: unverifiedProfile,
            policiesRepository: MockPoliciesRepository(delay: Duration.zero),
            delay: Duration.zero,
          );
      final PolicyQuote quote = await guardedRepository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      final PolicyApplication application =
          await MockPolicyApplicationRepository(
            delay: Duration.zero,
          ).submitApplication(
            _applicationRequest(product, configuration, quote),
          );
      final PremiumPayment paid =
          await MockPremiumPaymentRepository(delay: Duration.zero).payPremium(
            applicationId: application.id,
            quoteId: quote.id,
            amount: quote.totalPremium,
            method: PremiumPaymentMethod.bankTransfer,
            idempotencyKey: 'synthetic-unverified-key',
          );

      expect(
        () => guardedRepository.issuePolicy(
          PolicyIssuanceRequest(
            application: application,
            payment: paid,
            quote: quote,
          ),
        ),
        throwsA(isA<StateError>()),
      );

      final MockPolicyPurchaseRepository verifiedRepository =
          MockPolicyPurchaseRepository(
            identityRepository: profileRepository,
            policiesRepository: MockPoliciesRepository(delay: Duration.zero),
            delay: Duration.zero,
          );
      final PremiumPayment failed = PremiumPayment(
        id: 'PAYMENT-SYNTHETIC',
        applicationId: application.id,
        quoteId: quote.id,
        amount: quote.totalPremium,
        method: PremiumPaymentMethod.easypaisa,
        status: PremiumPaymentStatus.failed,
        idempotencyKey: 'synthetic-failed-key',
        reference: 'FAILED-SYNTHETIC',
        createdAt: DateTime.now(),
      );
      expect(
        () => verifiedRepository.issuePolicy(
          PolicyIssuanceRequest(
            application: application,
            payment: failed,
            quote: quote,
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

PolicyApplicationSubmissionRequest _applicationRequest(
  InsuranceProduct product,
  PolicyConfiguration configuration,
  PolicyQuote quote,
) => PolicyApplicationSubmissionRequest(
  product: product,
  configuration: configuration,
  details: TravelPolicyApplication(
    destination: 'Synthetic Destination',
    departureDate: DateTime.now().add(const Duration(days: 10)),
    returnDate: DateTime.now().add(const Duration(days: 20)),
    travellers: <TravelTraveller>[
      TravelTraveller(
        legalName: 'Synthetic Traveller',
        dateOfBirth: DateTime(1990),
      ),
    ],
    tripPurpose: 'Tourism',
    coverageRegion: 'Worldwide',
  ),
  beneficiaries: const <PolicyBeneficiary>[],
  quote: quote,
  applicantId: 'synthetic-user',
  applicantName: 'Synthetic Policyholder',
  maskedIdentityNumber: '*****-*******-3',
);
