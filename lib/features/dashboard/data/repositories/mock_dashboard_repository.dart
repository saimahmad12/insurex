import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MockDashboardRepository
    implements DashboardRepository {
  const MockDashboardRepository();

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    return const DashboardSummary(
      userName: 'Saim Ahmad',
      activePolicies: 2,
      activeClaims: 1,
      totalClaims: 3,
    );
  }
}