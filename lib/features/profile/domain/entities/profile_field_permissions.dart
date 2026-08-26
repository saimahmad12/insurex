import 'identity_verification.dart';

class ProfileFieldPermissions {
  const ProfileFieldPermissions({
    required this.canEditLegalName,
    required this.canEditDateOfBirth,
    required this.canEditGender,
    required this.canEditAddress,
    required this.canRequestEmailChange,
    required this.canRequestMobileChange,
    required this.canRequestIdentityCorrection,
  });

  factory ProfileFieldPermissions.forVerificationStatus(
    IdentityVerificationStatus status,
  ) {
    final bool legalIdentityIsEditable =
        status == IdentityVerificationStatus.notStarted;
    return ProfileFieldPermissions(
      canEditLegalName: legalIdentityIsEditable,
      canEditDateOfBirth: legalIdentityIsEditable,
      canEditGender: legalIdentityIsEditable,
      canEditAddress: true,
      canRequestEmailChange: true,
      canRequestMobileChange: true,
      canRequestIdentityCorrection: true,
    );
  }

  final bool canEditLegalName;
  final bool canEditDateOfBirth;
  final bool canEditGender;
  final bool canEditAddress;
  final bool canRequestEmailChange;
  final bool canRequestMobileChange;
  final bool canRequestIdentityCorrection;

  bool get canEditIdentityNumber => false;
}
