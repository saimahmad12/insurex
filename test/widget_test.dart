import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/core/widgets/glass_action_button.dart';
import 'package:insurancex/features/claims/application/controllers/my_claims_controller.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_filter.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_status_repository.dart';
import 'package:insurancex/features/claims/presentation/widgets/claim_filter_tabs.dart';
import 'package:insurancex/features/dashboard/application/controllers/dashboard_controller.dart';
import 'package:insurancex/features/dashboard/application/controllers/dashboard_navigation_controller.dart';
import 'package:insurancex/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:insurancex/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:insurancex/features/dashboard/presentation/pages/dashboard_navigation_shell.dart';
import 'package:insurancex/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:insurancex/features/policies/application/controllers/policies_controller.dart';
import 'package:insurancex/features/policies/domain/entities/insurance_policy.dart';
import 'package:insurancex/features/policies/domain/repositories/policies_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';

void main() {
  testWidgets('Splash screen displays primary content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    await tester.pumpAndSettle();

    expect(find.text('InsureX'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('main navigation keeps the bottom bar and tab state', (
    WidgetTester tester,
  ) async {
    final DashboardNavigationController navigationController =
        DashboardNavigationController();
    final _TestPoliciesRepository policiesRepository =
        _TestPoliciesRepository();
    final PoliciesController policiesController = PoliciesController(
      repository: policiesRepository,
    );
    final _TestClaimsRepository claimsRepository = _TestClaimsRepository();
    final MyClaimsController myClaimsController = MyClaimsController(
      repository: claimsRepository,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DashboardNavigationShell(
          navigationController: navigationController,
          dashboardController: DashboardController(
            repository: _TestDashboardRepository(),
          ),
          policiesController: policiesController,
          myClaimsController: myClaimsController,
          onFileClaim: () {},
          onClaimStatus: () {},
          onClaimPressed: (InsuranceClaim claim) {},
          onPayments: () {},
          onNotifications: () {},
          profilePage: const SizedBox(
            key: Key('test_profile_page'),
            child: Text('Test Profile'),
          ),
          onPolicySearch: () {},
          onPolicyPressed: (InsurancePolicy policy) {},
          onBuyPolicy: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      0,
    );

    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle();

    expect(find.text('My Policies'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      1,
    );

    await tester.tap(find.text('Expired'));
    await tester.pumpAndSettle();
    expect(policiesController.selectedFilter, PolicyFilter.expired);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle();

    expect(policiesController.selectedFilter, PolicyFilter.expired);
    expect(policiesRepository.getPoliciesCallCount, 1);

    await tester.tap(find.text('Claims'));
    await tester.pumpAndSettle();

    expect(navigationController.selectedTab, DashboardNavigationTab.claims);
    expect(find.text('My Claims'), findsOneWidget);
    expect(find.text('No claims yet'), findsOneWidget);
    expect(find.text('File a Claim'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      3,
    );
    expect(claimsRepository.getClaimsCallCount, 1);

    await tester.enterText(
      find.byKey(const Key('claim_search_field')),
      'preserved query',
    );
    await tester.pump();

    await tester.tap(find.text('Claims'));
    await tester.pumpAndSettle();
    expect(claimsRepository.getClaimsCallCount, 1);

    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle();
    expect(policiesController.selectedFilter, PolicyFilter.expired);
    expect(policiesRepository.getPoliciesCallCount, 1);

    await tester.tap(find.text('Claims'));
    await tester.pumpAndSettle();
    expect(myClaimsController.searchQuery, 'preserved query');
    expect(claimsRepository.getClaimsCallCount, 1);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(navigationController.selectedTab, DashboardNavigationTab.profile);
    expect(find.byKey(const Key('test_profile_page')), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      4,
    );

    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('test_profile_page')), findsOneWidget);
    expect(policiesController.selectedFilter, PolicyFilter.expired);
  });

  testWidgets(
    'Dashboard Claim Status opens a focused route and preserves shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(const InsureXApp());
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.dashboard));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
      await tester.ensureVisible(find.text('Claim Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Claim Status'));
      await tester.pumpAndSettle();

      expect(find.text('CLM20260826001'), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsNothing);

      await tester.tap(find.byKey(const Key('claim_status_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    },
  );

  testWidgets('Buy New Policy opens marketplace above the persistent shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Policies'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Buy New Policy'));
    await tester.tap(find.text('Buy New Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Insurance Marketplace'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsNothing);

    await tester.tap(find.byKey(const Key('profile_page_back_button')));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(find.text('My Policies'), findsOneWidget);
  });

  testWidgets(
    'Buy Now requires canonical CNIC verification for an unverified user',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const InsureXApp());
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.dashboard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Policies'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Buy New Policy'));
      await tester.tap(find.text('Buy New Policy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Worldwide Travel Protect'));
      await tester.pumpAndSettle();
      await tester.fling(find.byType(ListView), const Offset(0, -2400), 1200);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('product_buy_now_button')),
      );
      await tester.tap(find.byKey(const Key('product_buy_now_button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('configure_buy_now_button')),
      );
      await tester.tap(find.byKey(const Key('configure_buy_now_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Identity Verification'), findsOneWidget);
      expect(find.text('Before you continue'), findsOneWidget);
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const Key('identity_consent_checkbox')),
            )
            .value,
        isFalse,
      );
      expect(
        tester
            .widget<GlassActionButton>(
              find.byKey(const Key('identity_intro_continue_button')),
            )
            .onPressed,
        isNull,
      );
      expect(find.byType(DashboardBottomNavigation), findsNothing);

      await tester.tap(find.byKey(const Key('profile_page_back_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Configure Coverage'), findsOneWidget);
      await tester.tap(find.byKey(const Key('profile_page_back_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('product_buy_now_button')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Insurance Marketplace'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
      expect(find.text('My Policies'), findsOneWidget);
    },
  );

  testWidgets('claim card opens Claim Status and back preserves Claims state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Claims'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('claim_filter_rejected')),
    );
    await tester.enterText(
      find.byKey(const Key('claim_search_field')),
      'CLM20260822005',
    );
    await tester.pump(const Duration(milliseconds: 300));

    final Finder claimCard = find.byKey(
      const ValueKey<String>('claim_card_CLM20260822005'),
    );
    expect(claimCard, findsOneWidget);
    await tester.ensureVisible(claimCard);
    await tester.tap(claimCard);
    await tester.pumpAndSettle();

    expect(find.text('Claim Status'), findsOneWidget);
    expect(find.text('CLM20260822005'), findsOneWidget);
    expect(find.text('Rejected'), findsWidgets);

    await tester.tap(find.byKey(const Key('claim_status_back_button')));
    await tester.pumpAndSettle();

    expect(find.text('My Claims'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<ClaimFilterTabs>(find.byType(ClaimFilterTabs))
          .selectedFilter,
      ClaimFilter.rejected,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('claim_search_field')))
          .controller
          ?.text,
      'CLM20260822005',
    );
    expect(claimCard, findsOneWidget);
  });

  testWidgets('Track Claim opens Claim Status for the submitted claim ID', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(
      navigator.pushNamed(
        AppRoutes.claimSubmitted,
        arguments: ClaimSubmissionResult(
          claimId: 'CLM-2026-00124',
          submittedAt: DateTime(2026, 8, 26, 12),
          status: ClaimStatus.underReview,
          aiVerificationCompleted: true,
          blockchainRecordStatus: 'Pending Integration',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Track Claim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track Claim'));
    await tester.pumpAndSettle();

    expect(find.text('Claim Status'), findsOneWidget);
    expect(find.text('CLM-2026-00124'), findsOneWidget);
  });

  testWidgets('approved Claim Status opens the Receive Payment flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(
      navigator.pushNamed(
        AppRoutes.claimStatus,
        arguments: MockClaimStatusRepository.approvedClaimId,
      ),
    );
    await tester.pumpAndSettle();

    final Finder receivePayment = find.byKey(
      const Key('claim_status_contextual_action'),
    );
    expect(receivePayment, findsOneWidget);
    await tester.ensureVisible(receivePayment);
    await tester.pumpAndSettle();
    await tester.tap(receivePayment);
    await tester.pumpAndSettle();

    expect(find.text('Receive Payment'), findsOneWidget);
    expect(find.text('Saved Payout Methods'), findsOneWidget);
    expect(find.text('Rs. 105,000'), findsOneWidget);
  });

  testWidgets('Dashboard Payments opens history and an existing payout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    final Finder payments = find.text('Payments');
    await tester.ensureVisible(payments);
    await tester.tap(payments);
    await tester.pumpAndSettle();

    expect(find.text('Payment Processing'), findsOneWidget);
    final Finder payoutCard = find.byKey(
      const ValueKey<String>('payout_history_payout-processing-001'),
    );
    await tester.tap(payoutCard);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('payout_status_card')), findsOneWidget);
    expect(find.text('Payment Processing'), findsOneWidget);
  });

  testWidgets('Profile tab is persistent and shortcuts switch main tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_account_menu')), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      4,
    );

    await tester.ensureVisible(find.text('My Policies'));
    await tester.tap(find.text('My Policies'));
    await tester.pumpAndSettle();

    expect(find.text('My Policies'), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      1,
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('My Claims'));
    await tester.tap(find.text('My Claims'));
    await tester.pumpAndSettle();

    expect(find.text('My Claims'), findsOneWidget);
    expect(
      tester
          .widget<DashboardBottomNavigation>(
            find.byType(DashboardBottomNavigation),
          )
          .selectedIndex,
      3,
    );
  });

  testWidgets(
    'Personal Information saves editable address and keeps identity locked',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const InsureXApp(
          initialVerificationStatus: IdentityVerificationStatus.verified,
        ),
      );
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.dashboard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_personal_information')));
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsNothing);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const Key('edit_profile_name')),
                matching: find.byType(EditableText),
              ),
            )
            .readOnly,
        isTrue,
      );
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const Key('edit_profile_name')),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        'Saim Ahmad',
      );

      final Finder addressField = find.descendant(
        of: find.byKey(const Key('edit_profile_address')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(addressField);
      await tester.enterText(addressField, 'Apartment 12, Blue Area');
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      expect(find.text('Saim Ahmad'), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile_personal_information')));
      await tester.pumpAndSettle();
      final Finder reopenedAddressField = find.descendant(
        of: find.byKey(const Key('edit_profile_address')),
        matching: find.byType(TextFormField),
      );
      expect(
        tester.widget<TextFormField>(reopenedAddressField).controller?.text,
        'Apartment 12, Blue Area',
      );
      await tester.enterText(reopenedAddressField, 'Unsaved Address');
      await tester.tap(find.byKey(const Key('profile_page_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Saim Ahmad'), findsOneWidget);
      expect(find.text('Unsaved Address'), findsNothing);
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    },
  );

  testWidgets(
    'Identity Verification opens and system back returns to Profile',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const InsureXApp(
          initialVerificationStatus: IdentityVerificationStatus.verified,
        ),
      );
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.dashboard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_identity_verification')));
      await tester.pumpAndSettle();

      expect(find.text('Identity Verification'), findsOneWidget);
      expect(find.text('*****-*******-3'), findsOneWidget);
      expect(find.text('Identity Verified'), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_account_menu')), findsOneWidget);
      expect(find.text('Identity Verified'), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
    },
  );

  testWidgets(
    'successful Change Password returns through Security to Profile',
    (WidgetTester tester) async {
      await tester.pumpWidget(const InsureXApp());
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.dashboard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_settings_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('change_password_setting')));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsWidgets);
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('current_password_field')),
          matching: find.byType(TextFormField),
        ),
        'Current@123',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('new_password_field')),
          matching: find.byType(TextFormField),
        ),
        'NewSecure1',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('confirm_password_field')),
          matching: find.byType(TextFormField),
        ),
        'NewSecure1',
      );
      final Finder action = find.byKey(const Key('change_password_button'));
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_account_menu')), findsOneWidget);
      expect(find.byType(DashboardBottomNavigation), findsOneWidget);
      expect(find.text('Password changed successfully.'), findsOneWidget);
      expect(find.byKey(const Key('change_password_button')), findsNothing);
    },
  );

  testWidgets('Profile Payments opens the existing payments history route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();

    expect(find.text('Payment Processing'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsNothing);

    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_account_menu')), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsOneWidget);
  });

  testWidgets('Profile logout clears authenticated navigation history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.dashboard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_logout')));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_logout_button')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.byType(DashboardBottomNavigation), findsNothing);
    expect(navigator.canPop(), isFalse);
  });
}

class _TestDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    return const DashboardSummary(
      userName: 'Test User',
      activePolicies: 1,
      activeClaims: 0,
      totalClaims: 0,
    );
  }
}

class _TestPoliciesRepository implements PoliciesRepository {
  int getPoliciesCallCount = 0;
  final List<InsurancePolicy> issuedPolicies = <InsurancePolicy>[];

  @override
  Future<void> addIssuedPolicy(InsurancePolicy policy) async {
    issuedPolicies.add(policy);
  }

  @override
  Future<List<InsurancePolicy>> getPolicies() async {
    getPoliciesCallCount++;

    return <InsurancePolicy>[
      InsurancePolicy(
        id: 'expired-policy',
        policyNumber: 'INS-TEST-001',
        title: 'Test Policy',
        type: PolicyType.vehicle,
        validTill: DateTime(2025),
        premium: 100,
        status: PolicyStatus.expired,
      ),
    ];
  }
}

class _TestClaimsRepository implements ClaimStatusRepository {
  int getClaimsCallCount = 0;

  @override
  Future<List<InsuranceClaim>> getClaims() async {
    getClaimsCallCount++;
    return <InsuranceClaim>[];
  }

  @override
  Future<InsuranceClaim?> getClaimById(String claimId) async => null;

  @override
  Future<InsuranceClaim?> getMostRecentActiveClaim() async => null;
}
