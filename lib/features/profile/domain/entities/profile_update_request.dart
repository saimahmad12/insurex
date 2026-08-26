import 'user_address.dart';
import 'user_profile.dart';

class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    required this.address,
    this.fullName,
    this.dateOfBirth,
    this.gender,
  });

  final UserAddress address;
  final String? fullName;
  final DateTime? dateOfBirth;
  final ProfileGender? gender;

  bool get containsLegalIdentityChanges =>
      fullName != null || dateOfBirth != null || gender != null;
}
