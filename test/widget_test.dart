import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/theme/app_theme.dart';
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

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: DashboardNavigationShell(
          navigationController: navigationController,
          dashboardController: DashboardController(
            repository: _TestDashboardRepository(),
          ),
          policiesController: policiesController,
          onFileClaim: () {},
          onClaimStatus: () {},
          onPayments: () {},
          onNotifications: () {},
          onClaims: () {},
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
