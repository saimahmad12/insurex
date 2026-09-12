import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/seller_dashboard/application/controllers/seller_dashboard_controller.dart';
import 'package:insurancex/features/seller_dashboard/data/repositories/mock_seller_dashboard_repository.dart';
import 'package:insurancex/features/seller_dashboard/domain/entities/seller_dashboard.dart';
import 'package:insurancex/features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';

void main() {
  const SellerDashboardAccount approvedAccount = SellerDashboardAccount(
    companyName: 'Synthetic Assurance Ltd',
    businessEmail: 'approved@insurex.test',
    status: SellerDashboardAccountStatus.approved,
  );

  test('exposes loading then loaded data', () async {
    final Completer<SellerDashboard> completer = Completer<SellerDashboard>();
    final _ControlledRepository repository = _ControlledRepository(completer);
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: approvedAccount,
    );

    final Future<void> request = controller.loadDashboard();
    expect(controller.status, SellerDashboardStatus.loading);

    completer.complete(_dashboard());
    await request;

    expect(controller.status, SellerDashboardStatus.loaded);
    expect(controller.dashboard?.summary.activePolicies, 1248);
  });

  test('exposes an explicit empty state', () async {
    final SellerDashboardController controller = SellerDashboardController(
      repository: MockSellerDashboardRepository(
        scenario: MockSellerDashboardScenario.empty,
        delay: Duration.zero,
      ),
      account: approvedAccount,
    );

    await controller.loadDashboard();

    expect(controller.status, SellerDashboardStatus.empty);
    expect(controller.dashboard?.isEmpty, isTrue);
  });

  test('exposes failure and supports retry', () async {
    final MockSellerDashboardRepository repository =
        MockSellerDashboardRepository(
          scenario: MockSellerDashboardScenario.failure,
          delay: Duration.zero,
        );
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: approvedAccount,
    );

    await controller.loadDashboard();
    expect(controller.status, SellerDashboardStatus.failure);
    expect(controller.errorMessage, contains('Please try again'));

    repository.scenario = MockSellerDashboardScenario.loaded;
    await controller.loadDashboard();

    expect(controller.status, SellerDashboardStatus.loaded);
    expect(repository.requestCount, 2);
  });

  test(
    'refresh retains content and prevents duplicate refresh requests',
    () async {
      final _RefreshRepository repository = _RefreshRepository();
      final SellerDashboardController controller = SellerDashboardController(
        repository: repository,
        account: approvedAccount,
      );
      await controller.loadDashboard();
      final SellerDashboard initial = controller.dashboard!;

      final Future<void> refresh = controller.refreshDashboard();
      await controller.refreshDashboard();

      expect(controller.status, SellerDashboardStatus.refreshing);
      expect(controller.dashboard, same(initial));
      expect(repository.requestCount, 2);
      repository.refreshCompleter.complete(_dashboard(activePolicies: 1300));
      await refresh;

      expect(controller.status, SellerDashboardStatus.loaded);
      expect(controller.dashboard?.summary.activePolicies, 1300);
    },
  );

  test('prevents duplicate load and refresh requests', () async {
    final Completer<SellerDashboard> completer = Completer<SellerDashboard>();
    final _ControlledRepository repository = _ControlledRepository(completer);
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: approvedAccount,
    );

    final Future<void> first = controller.loadDashboard();
    await controller.loadDashboard();
    await controller.refreshDashboard();

    expect(repository.requestCount, 1);
    completer.complete(_dashboard());
    await first;
  });

  test('ignores an active request completion after disposal', () async {
    final Completer<SellerDashboard> completer = Completer<SellerDashboard>();
    final _ControlledRepository repository = _ControlledRepository(completer);
    final SellerDashboardController controller = SellerDashboardController(
      repository: repository,
      account: approvedAccount,
    );
    int notifications = 0;
    controller.addListener(() => notifications++);

    final Future<void> request = controller.loadDashboard();
    expect(notifications, 1);
    controller.dispose();
    completer.complete(_dashboard());

    await expectLater(request, completes);
    expect(notifications, 1);
  });

  test('blocks unavailable and non-approved seller accounts', () async {
    final MockSellerDashboardRepository repository =
        MockSellerDashboardRepository(delay: Duration.zero);
    final SellerDashboardController unavailable = SellerDashboardController(
      repository: repository,
      account: null,
    );
    final SellerDashboardController notApproved = SellerDashboardController(
      repository: repository,
      account: const SellerDashboardAccount(
        companyName: 'Pending Protection Ltd',
        businessEmail: 'pending@insurex.test',
        status: SellerDashboardAccountStatus.notApproved,
      ),
    );

    await unavailable.loadDashboard();
    await notApproved.loadDashboard();

    expect(unavailable.status, SellerDashboardStatus.accountUnavailable);
    expect(notApproved.status, SellerDashboardStatus.accountNotApproved);
    expect(repository.requestCount, 0);
  });
}

class _ControlledRepository implements SellerDashboardRepository {
  _ControlledRepository(this.completer);

  final Completer<SellerDashboard> completer;
  int requestCount = 0;

  @override
  Future<SellerDashboard> getDashboard({required String businessEmail}) {
    requestCount++;
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
