import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/notification_preferences_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_notification_preferences_repository.dart';
import 'package:insurancex/features/profile/domain/entities/notification_preferences.dart';

void main() {
  group('NotificationPreferencesController', () {
    test('loads and saves only changed preferences', () async {
      final MockNotificationPreferencesRepository repository =
          MockNotificationPreferencesRepository(delay: Duration.zero);
      final NotificationPreferencesController controller =
          NotificationPreferencesController(repository: repository);
      await controller.initialize();

      expect(
        await controller.updatePreference(
          NotificationPreference.securityAlerts,
          true,
        ),
        isFalse,
      );
      expect(repository.updateCallCount, 0);
      expect(
        await controller.updatePreference(
          NotificationPreference.promotionalNotifications,
          true,
        ),
        isTrue,
      );
      expect(controller.preferences?.promotionalNotifications, isTrue);
      expect(repository.updateCallCount, 1);
    });

    test(
      'failed update restores old values without full-page loading',
      () async {
        final NotificationPreferencesController controller =
            NotificationPreferencesController(
              repository: MockNotificationPreferencesRepository(
                delay: Duration.zero,
                failUpdate: true,
              ),
            );
        await controller.initialize();
        final NotificationPreferences original = controller.preferences!;

        expect(
          await controller.updatePreference(
            NotificationPreference.claimDecisions,
            false,
          ),
          isFalse,
        );
        expect(controller.preferences, original);
        expect(controller.isLoading, isFalse);
        expect(
          controller.updateStatus,
          NotificationPreferenceUpdateStatus.failure,
        );
      },
    );
  });
}
