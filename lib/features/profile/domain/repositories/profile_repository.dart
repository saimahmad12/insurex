import '../entities/profile_update_request.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> getProfile();

  Future<UserProfile> updateProfile(ProfileUpdateRequest request);

  Future<UserProfile?> refreshProfile();
}
