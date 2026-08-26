import '../entities/notification_preferences.dart';

abstract interface class NotificationPreferencesRepository {
  Future<NotificationPreferences> getPreferences();

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  );
}
