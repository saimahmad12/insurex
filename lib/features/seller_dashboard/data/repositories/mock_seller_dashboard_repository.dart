import '../../domain/entities/seller_dashboard.dart';
import '../../domain/repositories/seller_dashboard_repository.dart';

enum MockSellerDashboardScenario { loaded, empty, failure }

class MockSellerDashboardRepository implements SellerDashboardRepository {
  MockSellerDashboardRepository({
    this.scenario = MockSellerDashboardScenario.loaded,
    this.delay = const Duration(milliseconds: 650),
  });

  MockSellerDashboardScenario scenario;
  final Duration delay;

  int requestCount = 0;
  String? lastBusinessEmail;

  @override
  Future<SellerDashboard> getDashboard({required String businessEmail}) async {
    requestCount++;
    lastBusinessEmail = businessEmail;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return switch (scenario) {
      MockSellerDashboardScenario.loaded => _loadedDashboard(),
      MockSellerDashboardScenario.empty => _emptyDashboard(),
      MockSellerDashboardScenario.failure => throw StateError(
        'Synthetic seller dashboard failure.',
      ),
    };
  }

  static SellerDashboard _loadedDashboard() {
    return SellerDashboard(
      summary: const SellerDashboardSummary(
        activeProducts: 12,
        pendingApplications: 18,
        activePolicies: 1248,
        openClaims: 23,
        premiumCollected: 18450000,
        pendingSettlements: 2375000,
      ),
      recentApplications: <SellerRecentApplication>[
        SellerRecentApplication(
          reference: 'APP-SYN-1048',
          applicantName: 'Ayesha Rahman',
          productName: 'Secure Health Plus',
          submittedAt: DateTime(2026, 9, 5, 9, 20),
          status: SellerApplicationStatus.awaitingReview,
        ),
        SellerRecentApplication(
          reference: 'APP-SYN-1047',
          applicantName: 'Hamza Iqbal',
          productName: 'DriveGuard Comprehensive',
          submittedAt: DateTime(2026, 9, 4, 16, 45),
          status: SellerApplicationStatus.documentsRequired,
        ),
        SellerRecentApplication(
          reference: 'APP-SYN-1046',
          applicantName: 'Sara Khan',
          productName: 'Family Life Shield',
          submittedAt: DateTime(2026, 9, 4, 11, 10),
          status: SellerApplicationStatus.approved,
        ),
      ],
      recentClaims: <SellerRecentClaim>[
        SellerRecentClaim(
          reference: 'CLM-SYN-7821',
          policyHolderName: 'Bilal Ahmed',
          category: 'Vehicle',
          claimedAmount: 385000,
          submittedAt: DateTime(2026, 9, 5, 8, 5),
          status: SellerClaimStatus.underReview,
        ),
        SellerRecentClaim(
          reference: 'CLM-SYN-7819',
          policyHolderName: 'Mariam Ali',
          category: 'Health',
          claimedAmount: 127500,
          submittedAt: DateTime(2026, 9, 3, 14, 30),
          status: SellerClaimStatus.evidenceRequired,
        ),
        SellerRecentClaim(
          reference: 'CLM-SYN-7815',
          policyHolderName: 'Usman Tariq',
          category: 'Property',
          claimedAmount: 910000,
          submittedAt: DateTime(2026, 9, 2, 10, 15),
          status: SellerClaimStatus.settlementReady,
        ),
      ],
      salesOverview: const <SellerSalesPoint>[
        SellerSalesPoint(label: 'Apr', premium: 2250000),
        SellerSalesPoint(label: 'May', premium: 2780000),
        SellerSalesPoint(label: 'Jun', premium: 2640000),
        SellerSalesPoint(label: 'Jul', premium: 3210000),
        SellerSalesPoint(label: 'Aug', premium: 3540000),
        SellerSalesPoint(label: 'Sep', premium: 4030000),
      ],
      categoryPerformance: const <SellerPolicyCategoryPerformance>[
        SellerPolicyCategoryPerformance(
          category: 'Health',
          activePolicies: 486,
          premiumCollected: 7120000,
          share: 0.39,
        ),
        SellerPolicyCategoryPerformance(
          category: 'Vehicle',
          activePolicies: 362,
          premiumCollected: 5290000,
          share: 0.29,
        ),
        SellerPolicyCategoryPerformance(
          category: 'Life',
          activePolicies: 247,
          premiumCollected: 3710000,
          share: 0.20,
        ),
        SellerPolicyCategoryPerformance(
          category: 'Property',
          activePolicies: 153,
          premiumCollected: 2330000,
          share: 0.12,
        ),
      ],
      generatedAt: DateTime(2026, 9, 5, 10, 30),
    );
  }

  static SellerDashboard _emptyDashboard() {
    return SellerDashboard(
      summary: const SellerDashboardSummary(
        activeProducts: 0,
        pendingApplications: 0,
        activePolicies: 0,
        openClaims: 0,
        premiumCollected: 0,
        pendingSettlements: 0,
      ),
      recentApplications: const <SellerRecentApplication>[],
      recentClaims: const <SellerRecentClaim>[],
      salesOverview: const <SellerSalesPoint>[],
      categoryPerformance: const <SellerPolicyCategoryPerformance>[],
      generatedAt: DateTime(2026, 9, 5, 10, 30),
    );
  }
}
