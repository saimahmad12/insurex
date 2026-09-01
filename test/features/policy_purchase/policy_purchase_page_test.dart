import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'package:insurancex/features/policies/data/repositories/mock_policies_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_application_controller.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_purchase_controller.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_quote_controller.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/premium_payment_controller.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_policy_application_repository.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_policy_purchase_repository.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_premium_payment_repository.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/beneficiary.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_application.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/policy_application_details.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/premium_payment.dart';
import 'package:insurancex/features/policy_purchase/presentation/pages/policy_purchase_page.dart';

void main() {
  testWidgets('verified policyholder configures coverage and continues', (
    WidgetTester tester,
  ) async {
    final MockProfileRepository profile = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockInsuranceMarketplaceRepository marketplace =
        MockInsuranceMarketplaceRepository(delay: Duration.zero);
    final MockPolicyPurchaseRepository purchase = MockPolicyPurchaseRepository(
      identityRepository: profile,
      policiesRepository: MockPoliciesRepository(delay: Duration.zero),
      delay: Duration.zero,
    );
    int identityRouteCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PolicyPurchasePage(
          purchaseController: PolicyPurchaseController(
            marketplaceRepository: marketplace,
            profileRepository: profile,
            purchaseRepository: purchase,
            productId: 'travel-worldwide-01',
          ),
          quoteController: PolicyQuoteController(repository: purchase),
          applicationController: PolicyApplicationController(
            repository: MockPolicyApplicationRepository(delay: Duration.zero),
          ),
          paymentController: PremiumPaymentController(
            repository: MockPremiumPaymentRepository(delay: Duration.zero),
          ),
          onBack: () {},
          onVerifyIdentity: () async {
            identityRouteCalls++;
            return null;
          },
          onViewPolicy: (_) {},
          onViewPaymentReceipt: (_) {},
          onMyPolicies: () {},
          onDashboard: () {},
          onDownloadDocument: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configure Coverage'), findsOneWidget);
    expect(find.textContaining('authoritative final quote'), findsOneWidget);
    await tester.fling(find.byType(ListView), const Offset(0, -1600), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('configure_buy_now_button')));
    await tester.pumpAndSettle();

    expect(identityRouteCalls, 0);
    expect(find.text('Policy Application'), findsOneWidget);
    expect(find.text('Travel Information'), findsOneWidget);
  });

  testWidgets(
    'unverified policyholder is sent to canonical identity verification',
    (WidgetTester tester) async {
      final MockProfileRepository profile = MockProfileRepository(
        delay: Duration.zero,
        initialVerificationStatus: IdentityVerificationStatus.notStarted,
      );
      final MockInsuranceMarketplaceRepository marketplace =
          MockInsuranceMarketplaceRepository(delay: Duration.zero);
      final MockPolicyPurchaseRepository purchase =
          MockPolicyPurchaseRepository(
            identityRepository: profile,
            policiesRepository: MockPoliciesRepository(delay: Duration.zero),
            delay: Duration.zero,
          );
      int identityRouteCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: PolicyPurchasePage(
            purchaseController: PolicyPurchaseController(
              marketplaceRepository: marketplace,
              profileRepository: profile,
              purchaseRepository: purchase,
              productId: 'travel-worldwide-01',
            ),
            quoteController: PolicyQuoteController(repository: purchase),
            applicationController: PolicyApplicationController(
              repository: MockPolicyApplicationRepository(delay: Duration.zero),
            ),
            paymentController: PremiumPaymentController(
              repository: MockPremiumPaymentRepository(delay: Duration.zero),
            ),
            onBack: () {},
            onVerifyIdentity: () async {
              identityRouteCalls++;
              return null;
            },
            onViewPolicy: (_) {},
            onViewPaymentReceipt: (_) {},
            onMyPolicies: () {},
            onDashboard: () {},
            onDownloadDocument: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.byType(ListView), const Offset(0, -1600), 1000);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('configure_buy_now_button')));
      await tester.pumpAndSettle();

      expect(identityRouteCalls, 1);
      expect(find.text('Configure Coverage'), findsOneWidget);
      expect(find.text('Policy Application'), findsNothing);
    },
  );

  testWidgets('coverage selections preserve the loaded form and values', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final MockProfileRepository profile = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockInsuranceMarketplaceRepository marketplace =
        MockInsuranceMarketplaceRepository(delay: Duration.zero);
    final MockPolicyPurchaseRepository purchase = MockPolicyPurchaseRepository(
      identityRepository: profile,
      policiesRepository: MockPoliciesRepository(delay: Duration.zero),
      delay: Duration.zero,
    );
    final PolicyPurchaseController controller = PolicyPurchaseController(
      marketplaceRepository: marketplace,
      profileRepository: profile,
      purchaseRepository: purchase,
      productId: 'travel-worldwide-01',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PolicyPurchasePage(
          purchaseController: controller,
          quoteController: PolicyQuoteController(repository: purchase),
          applicationController: PolicyApplicationController(
            repository: MockPolicyApplicationRepository(delay: Duration.zero),
          ),
          paymentController: PremiumPaymentController(
            repository: MockPremiumPaymentRepository(delay: Duration.zero),
          ),
          onBack: () {},
          onVerifyIdentity: () async => null,
          onViewPolicy: (_) {},
          onViewPaymentReceipt: (_) {},
          onMyPolicies: () {},
          onDashboard: () {},
          onDownloadDocument: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('coverage_amount_slider')),
      const Offset(90, 0),
    );
    await tester.pump();
    await _selectDropdown(
      tester,
      const Key('coverage_duration_dropdown'),
      '12 months',
    );
    await _selectDropdown(
      tester,
      const Key('coverage_deductible_dropdown'),
      'PKR 10000',
    );
    await _selectDropdown(
      tester,
      const Key('coverage_frequency_dropdown'),
      'Quarterly',
    );
    await _selectDropdown(tester, const Key('coverage_people_dropdown'), '2');
    final Finder addOn = find.byKey(
      const ValueKey<String>('coverage_add_on_Emergency assistance'),
    );
    await tester.ensureVisible(addOn);
    await tester.tap(addOn);
    await tester.pump();

    expect(
      find.byKey(const Key('policy_purchase_initial_loader')),
      findsNothing,
    );
    expect(find.text('Configure Coverage'), findsOneWidget);
    expect(find.byKey(const Key('coverage_estimated_premium')), findsOneWidget);
    expect(controller.loadStatus, PolicyPurchaseLoadStatus.success);
    expect(controller.configuration?.durationMonths, 12);
    expect(controller.configuration?.deductible, 10000);
    expect(controller.configuration?.paymentFrequency.name, 'quarterly');
    expect(controller.configuration?.insuredPeople, 2);
    expect(controller.configuration?.addOns, contains('Emergency assistance'));
  });

  testWidgets('premium payment offers bank and wallets without Card', (
    WidgetTester tester,
  ) async {
    final MockProfileRepository profile = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockInsuranceMarketplaceRepository marketplace =
        MockInsuranceMarketplaceRepository(delay: Duration.zero);
    final MockPolicyPurchaseRepository purchase = MockPolicyPurchaseRepository(
      identityRepository: profile,
      policiesRepository: MockPoliciesRepository(delay: Duration.zero),
      delay: Duration.zero,
    );
    final PolicyPurchaseController purchaseController =
        PolicyPurchaseController(
          marketplaceRepository: marketplace,
          profileRepository: profile,
          purchaseRepository: purchase,
          productId: 'travel-worldwide-01',
        );
    final PolicyQuoteController quoteController = PolicyQuoteController(
      repository: purchase,
    );
    final PolicyApplicationController applicationController =
        PolicyApplicationController(
          repository: MockPolicyApplicationRepository(delay: Duration.zero),
        );
    await purchaseController.initialize();
    final details = TravelPolicyApplication(
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
    );
    purchaseController.updateApplicationDetails(details);
    final quote = await quoteController.generate(
      product: purchaseController.product!,
      configuration: purchaseController.configuration!,
    );
    applicationController.application = PolicyApplication(
      id: 'APP-SYNTHETIC',
      request: PolicyApplicationSubmissionRequest(
        product: purchaseController.product!,
        configuration: purchaseController.configuration!,
        details: details,
        beneficiaries: const <PolicyBeneficiary>[],
        quote: quote!,
        applicantId: 'synthetic-user',
        applicantName: 'Synthetic Policyholder',
        maskedIdentityNumber: '*****-*******-3',
      ),
      status: PolicyApplicationStatus.approved,
      submittedAt: DateTime.now(),
    );
    purchaseController.goTo(PolicyPurchaseStep.payment);
    final PremiumPaymentController paymentController = PremiumPaymentController(
      repository: MockPremiumPaymentRepository(delay: Duration.zero),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PolicyPurchasePage(
          purchaseController: purchaseController,
          quoteController: quoteController,
          applicationController: applicationController,
          paymentController: paymentController,
          onBack: () {},
          onVerifyIdentity: () async => null,
          onViewPolicy: (_) {},
          onViewPaymentReceipt: (_) {},
          onMyPolicies: () {},
          onDashboard: () {},
          onDownloadDocument: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Card'), findsNothing);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('Easypaisa'), findsOneWidget);
    expect(find.text('JazzCash'), findsOneWidget);
    expect(paymentController.selectedMethod, PremiumPaymentMethod.bankTransfer);
    await tester.tap(
      find.byKey(const ValueKey<String>('premium_payment_method_easypaisa')),
    );
    await tester.pump();
    expect(paymentController.selectedMethod, PremiumPaymentMethod.easypaisa);
  });
}

Future<void> _selectDropdown(
  WidgetTester tester,
  Key key,
  String option,
) async {
  final Finder field = find.byKey(key);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('policy_purchase_initial_loader')), findsNothing);
}
