import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/seller_dashboard/application/controllers/seller_dashboard_controller.dart';
import 'package:insurancex/features/seller_dashboard/application/controllers/seller_dashboard_navigation_controller.dart';
import 'package:insurancex/features/seller_dashboard/data/repositories/mock_seller_dashboard_repository.dart';
import 'package:insurancex/features/seller_dashboard/domain/entities/seller_dashboard.dart';
import 'package:insurancex/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';
import 'package:insurancex/features/seller_dashboard/presentation/pages/seller_dashboard_navigation_shell.dart';
import 'package:insurancex/features/seller_dashboard/presentation/pages/seller_dashboard_page.dart';

void main() {
  const SellerDashboardAccount account = SellerDashboardAccount(
    companyName: 'Synthetic Assurance Ltd',
    businessEmail: 'approved@insurex.test',
    status: SellerDashboardAccountStatus.approved,
  );

  testWidgets('renders initial loading then loaded dashboard', (
    WidgetTester tester,
  ) async {
    final Completer<SellerDashboard> completer = Completer<SellerDashboard>();
    final SellerDashboardController controller = SellerDashboardController(
      repository: _ControlledRepository(completer),
      account: account,
    );
    unawaited(controller.loadDashboard());

    await _pumpDashboard(tester, controller);
    expect(find.byKey(const Key('seller_dashboard_loading')), findsOneWidget);

    completer.complete(_dashboard());
    await tester.pumpAndSettle();

    expect(find.text('Synthetic Assurance Ltd'), findsOneWidget);
    expect(find.text('Company Summary'), findsOneWidget);
  });

  testWidgets('renders summary values and recent synthetic activity', (
    WidgetTester tester,
  ) async {
    final SellerDashboardController controller = await _loadedController(
      account,
    );

    await _pumpDashboard(tester, controller);

    expect(find.text('12'), findsOneWidget);
    expect(find.text('1,248'), findsOneWidget);
    expect(find.text('PKR 18,450,000'), findsOneWidget);
    expect(find.text('Ayesha Rahman'), findsOneWidget);
    expect(find.text('APP-SYN-1048  •  5 Sep 2026'), findsOneWidget);
    expect(find.text('Bilal Ahmed'), findsOneWidget);
    expect(find.textContaining('PKR 385,000'), findsOneWidget);
    expect(find.text('Sales Overview'), findsOneWidget);
    expect(find.text('Policy Category Performance'), findsOneWidget);
  });

  testWidgets('mobile header has no Back and keeps notification and refresh', (
    WidgetTester tester,
  ) async {
    final SellerDashboardController controller = await _loadedController(
      account,
    );

    await _pumpDashboard(tester, controller);

    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    expect(
      find.byKey(const Key('seller_dashboard_notifications')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('seller_dashboard_refresh')), findsOneWidget);
  });

  testWidgets('Home omits Quick Actions and Logout', (
    WidgetTester tester,
  ) async {
    final SellerDashboardController controller = await _loadedController(
      account,
    );

    await _pumpDashboard(tester, controller);

    expect(find.text('Quick Actions'), findsNothing);
    expect(find.byKey(const Key('seller_dashboard_logout')), findsNothing);
    for (final String action in <String>[
      'add_product',
      'review_applications',
      'review_claims',
      'view_reports',
    ]) {
      expect(find.byKey(Key('seller_action_$action')), findsNothing);
    }
  });

  testWidgets('bottom navigation is visible with Home selected', (
    WidgetTester tester,
  ) async {
    final SellerDashboardController controller = await _loadedController(
      account,
    );

    await _pumpDashboard(tester, controller);

    expect(find.byKey(const Key('seller_bottom_navigation')), findsOneWidget);
    expect(
      find.byKey(const Key('seller_navigation_home_selected')),
      findsOneWidget,
    );
    for (final String label in <String>[
      'Home',
      'Products',
      'Applications',
      'Claims',
      'Profile',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('renders explicit empty state with zero summaries', (
    WidgetTester tester,
  ) async {
    final SellerDashboardController controller = SellerDashboardController(
      repository: MockSellerDashboardRepository(
        scenario: MockSellerDashboardScenario.empty,
        delay: Duration.zero,
      ),
      account: account,
    );
    await controller.loadDashboard();

    await _pumpDashboard(tester, controller);

    expect(find.byKey(const Key('seller_dashboard_empty')), findsOneWidget);
    expect(find.text('No dashboard activity yet'), findsOneWidget);
    expect(
      find.byKey(const Key('seller_summary_active_products')),
      findsOneWidget,
    );
  });

  testWidgets('renders error and retries successfully', (
    WidgetTester tester,
  ) async {
    final MockSellerDashboardRepository repository =
        MockSellerDashboardRepository(
          scenario: MockSellerDashboardScenario.failure,
          delay: Duration.zero,
        );
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: account,
    );
    await controller.loadDashboard();
    await _pumpDashboard(tester, controller);

    expect(find.byKey(const Key('seller_dashboard_error')), findsOneWidget);

    repository.scenario = MockSellerDashboardScenario.loaded;
    await tester.tap(find.byKey(const Key('seller_dashboard_state_action')));
    await tester.pumpAndSettle();

    expect(find.text('Synthetic Assurance Ltd'), findsOneWidget);
    expect(repository.requestCount, 2);
  });

  testWidgets('refresh keeps existing page content visible', (
    WidgetTester tester,
  ) async {
    final _RefreshRepository repository = _RefreshRepository();
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: account,
    );
    await controller.loadDashboard();
    await _pumpDashboard(tester, controller);

    await tester.tap(find.byKey(const Key('seller_dashboard_refresh')));
    await tester.pump();

    expect(
      find.byKey(const Key('seller_dashboard_refreshing')),
      findsOneWidget,
    );
    expect(find.text('PKR 18,450,000'), findsOneWidget);

    repository.refreshCompleter.complete(_dashboard(activePolicies: 1300));
    await tester.pumpAndSettle();

    expect(find.text('1,300'), findsOneWidget);
  });

  testWidgets('renders unavailable and not-approved account states', (
    WidgetTester tester,
  ) async {
    final SellerDashboardRepository repository = MockSellerDashboardRepository(
      delay: Duration.zero,
    );
    final SellerDashboardController unavailable = SellerDashboardController(
      repository: repository,
      account: null,
    );

    await _pumpDashboard(tester, unavailable);
    expect(
      find.byKey(const Key('seller_dashboard_account_unavailable')),
      findsOneWidget,
    );

    final SellerDashboardController notApproved = SellerDashboardController(
      repository: repository,
      account: const SellerDashboardAccount(
        companyName: 'Pending Protection Ltd',
        businessEmail: 'pending@insurex.test',
        status: SellerDashboardAccountStatus.notApproved,
      ),
    );
    await _pumpDashboard(tester, notApproved);
    expect(
      find.byKey(const Key('seller_dashboard_not_approved')),
      findsOneWidget,
    );
  });

  testWidgets('renders at narrow mobile width without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final SellerDashboardController controller = await _loadedController(
      account,
    );

    await _pumpDashboard(tester, controller);
    await tester.scrollUntilVisible(
      find.text('Policy Category Performance'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Policy Category Performance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation remains fixed while content scrolls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final SellerDashboardController controller = await _loadedController(
      account,
    );
    await _pumpDashboard(tester, controller);
    final Finder navigation = find.byKey(const Key('seller_bottom_navigation'));
    final double initialBottom = tester.getBottomRight(navigation).dy;

    await tester.scrollUntilVisible(
      find.text('Policy Category Performance'),
      350,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('seller_bottom_navigation')), findsOneWidget);
    expect(tester.getBottomRight(navigation).dy, initialBottom);
    expect(tester.takeException(), isNull);
  });
}

Future<SellerDashboardController> _loadedController(
  SellerDashboardAccount account,
) async {
  final SellerDashboardController controller = SellerDashboardController(
    repository: MockSellerDashboardRepository(delay: Duration.zero),
    account: account,
  );
  await controller.loadDashboard();
  return controller;
}

Future<void> _pumpDashboard(
  WidgetTester tester,
  SellerDashboardController controller,
) {
  final SellerDashboardNavigationController navigationController =
      SellerDashboardNavigationController();
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: SellerDashboardNavigationShell(
        navigationController: navigationController,
        onUnavailableDestination: () {},
        home: SellerDashboardPage(
          controller: controller,
          onNotifications: () {},
          onReturnToLogin: () {},
        ),
      ),
    ),
  );
}

class _ControlledRepository implements SellerDashboardRepository {
  _ControlledRepository(this.completer);

  final Completer<SellerDashboard> completer;

  @override
  Future<SellerDashboard> getDashboard({required String businessEmail}) {
    return completer.future;
  }
}

class _RefreshRepository implements SellerDashboardRepository {
  final Completer<SellerDashboard> refreshCompleter =
      Completer<SellerDashboard>();
  int requestCount = 0;

  @override
  Future<SellerDashboard> getDashboard({required String businessEmail}) {
    requestCount++;
    return requestCount == 1
        ? Future<SellerDashboard>.value(_dashboard())
        : refreshCompleter.future;
  }
}

SellerDashboard _dashboard({int activePolicies = 1248}) {
  return SellerDashboard(
    summary: SellerDashboardSummary(
      activeProducts: 12,
      pendingApplications: 18,
      activePolicies: activePolicies,
      openClaims: 23,
      premiumCollected: 18450000,
      pendingSettlements: 2375000,
    ),
    recentApplications: <SellerRecentApplication>[
      SellerRecentApplication(
        reference: 'APP-SYN-1048',
        applicantName: 'Ayesha Rahman',
        productName: 'Secure Health Plus',
        submittedAt: DateTime(2026, 9, 5),
        status: SellerApplicationStatus.awaitingReview,
      ),
    ],
    recentClaims: <SellerRecentClaim>[
      SellerRecentClaim(
        reference: 'CLM-SYN-7821',
        policyHolderName: 'Bilal Ahmed',
        category: 'Vehicle',
        claimedAmount: 385000,
        submittedAt: DateTime(2026, 9, 5),
        status: SellerClaimStatus.underReview,
      ),
    ],
    salesOverview: const <SellerSalesPoint>[
      SellerSalesPoint(label: 'Sep', premium: 4030000),
    ],
    categoryPerformance: const <SellerPolicyCategoryPerformance>[
      SellerPolicyCategoryPerformance(
        category: 'Health',
        activePolicies: 486,
        premiumCollected: 7120000,
        share: 0.39,
      ),
    ],
    generatedAt: DateTime(2026, 9, 5),
  );
}
