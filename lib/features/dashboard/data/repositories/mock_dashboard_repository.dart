import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final profile = await _profileRepository.getProfile();
    if (profile == null) {
      throw StateError('The account profile is unavailable.');
    }
    return DashboardSummary(
      userName: profile.fullName,
      activePolicies: 2,
      activeClaims: 1,
      totalClaims: 3,
    );
  }
}
