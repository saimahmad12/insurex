import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/profile_field_permissions.dart';

void main() {
  group('ProfileFieldPermissions', () {
    test('allows legal fields only before identity verification starts', () {
      final ProfileFieldPermissions permissions =
          ProfileFieldPermissions.forVerificationStatus(
            IdentityVerificationStatus.notStarted,
          );

      expect(permissions.canEditLegalName, isTrue);
      expect(permissions.canEditDateOfBirth, isTrue);
      expect(permissions.canEditGender, isTrue);
      expect(permissions.canEditIdentityNumber, isFalse);
      expect(permissions.canEditAddress, isTrue);
    });

    for (final IdentityVerificationStatus status
        in <IdentityVerificationStatus>[
          IdentityVerificationStatus.pending,
          IdentityVerificationStatus.verified,
          IdentityVerificationStatus.rejected,
        ]) {
      test('locks legal identity fields when status is ${status.name}', () {
        final ProfileFieldPermissions permissions =
            ProfileFieldPermissions.forVerificationStatus(status);

        expect(permissions.canEditLegalName, isFalse);
        expect(permissions.canEditDateOfBirth, isFalse);
        expect(permissions.canEditGender, isFalse);
        expect(permissions.canEditIdentityNumber, isFalse);
        expect(permissions.canEditAddress, isTrue);
        expect(permissions.canRequestIdentityCorrection, isTrue);
      });
    }

    test('contact information requires dedicated verified-change flows', () {
      final ProfileFieldPermissions permissions =
          ProfileFieldPermissions.forVerificationStatus(
            IdentityVerificationStatus.verified,
          );

      expect(permissions.canRequestEmailChange, isTrue);
      expect(permissions.canRequestMobileChange, isTrue);
    });
  });
}
