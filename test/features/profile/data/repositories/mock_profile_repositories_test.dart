import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_notification_preferences_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_security_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/notification_preferences.dart';
import 'package:insurancex/features/profile/domain/entities/profile_update_request.dart';
import 'package:insurancex/features/profile/domain/entities/user_address.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';

void main() {
  group('Profile mock repositories', () {
    test(
      'editable updates preserve protected identity and contact data',
      () async {
        final MockProfileRepository repository = MockProfileRepository(
          delay: Duration.zero,
        );
        final UserProfile profile = (await repository.getProfile())!;
        expect(profile.role, 'Policyholder');
        expect(
          profile.identityVerification.status,
          IdentityVerificationStatus.verified,
        );
        expect(profile.maskedIdentityNumber, '*****-*******-3');

        final UserProfile updated = await repository.updateProfile(
          ProfileUpdateRequest(
            address: const UserAddress(
              residentialAddress: 'House 10, Street 2',
              city: 'Lahore',
              country: 'Pakistan',
            ),
          ),
        );
        expect(updated.address.city, 'Lahore');
        expect(updated.fullName, profile.fullName);
        expect(updated.emailAddress, profile.emailAddress);
        expect(updated.mobileNumber, profile.mobileNumber);
        expect(updated.maskedIdentityNumber, '*****-*******-3');
      },
    );

    test('repository rejects verified legal identity changes', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
      );
      final UserProfile profile = (await repository.getProfile())!;

      await expectLater(
        repository.updateProfile(
          const ProfileUpdateRequest(
            fullName: 'Changed Legal Name',
            address: UserAddress(
              residentialAddress: 'House 10, Street 2',
              city: 'Lahore',
              country: 'Pakistan',
            ),
          ),
        ),
        throwsStateError,
      );
      expect((await repository.getProfile())?.fullName, profile.fullName);
    });

    test(
      'notification failure does not persist proposed preferences',
      () async {
        const NotificationPreferences original = NotificationPreferences(
          claimStatusUpdates: true,
          aiAnalysisCompletion: true,
          additionalEvidenceRequests: true,
          claimDecisions: true,
          paymentUpdates: true,
          policyExpiryReminders: true,
          securityAlerts: true,
          promotionalNotifications: false,
        );
        final MockNotificationPreferencesRepository repository =
            MockNotificationPreferencesRepository(
              delay: Duration.zero,
              failUpdate: true,
              initialPreferences: original,
            );
        await expectLater(
          repository.updatePreferences(
            original.withPreference(
              NotificationPreference.promotionalNotifications,
              true,
            ),
          ),
          throwsStateError,
        );
        expect(await repository.getPreferences(), original);
      },
    );

    test('password failure and logout outcomes are configurable', () async {
      final MockSecurityRepository security = MockSecurityRepository(
        delay: Duration.zero,
        failPasswordChange: true,
      );
      await expectLater(
        security.changePassword(
          currentPassword: 'Current123',
          newPassword: 'Secure123',
        ),
        throwsStateError,
      );

      final MockAuthSessionRepository session = MockAuthSessionRepository(
        delay: Duration.zero,
      );
      await session.logout();
      expect(session.sessionActive, isFalse);
    });
  });
}
