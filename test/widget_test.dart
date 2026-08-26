import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/application/controllers/my_claims_controller.dart';
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
          onProfile: () {},
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
