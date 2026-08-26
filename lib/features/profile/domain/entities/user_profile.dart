import 'identity_verification.dart';
import 'user_address.dart';

enum ProfileGender { female, male, other, preferNotToSay }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.emailAddress,
    required this.mobileNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.maskedIdentityNumber,
    required this.address,
    required this.role,
    required this.identityVerification,
  });

  final String id;
  final String fullName;
  final String emailAddress;
  final String mobileNumber;
  final DateTime dateOfBirth;
  final ProfileGender gender;
  final String maskedIdentityNumber;
  final UserAddress address;
  final String role;
  final IdentityVerification identityVerification;

  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'IX';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? fullName,
    String? emailAddress,
    String? mobileNumber,
    DateTime? dateOfBirth,
    ProfileGender? gender,
    String? maskedIdentityNumber,
    UserAddress? address,
    String? role,
    IdentityVerification? identityVerification,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      emailAddress: emailAddress ?? this.emailAddress,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      maskedIdentityNumber: maskedIdentityNumber ?? this.maskedIdentityNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      identityVerification: identityVerification ?? this.identityVerification,
    );
  }
}
