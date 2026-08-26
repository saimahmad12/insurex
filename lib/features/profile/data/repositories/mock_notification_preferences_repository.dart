import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';

class MockNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  MockNotificationPreferencesRepository({
    this.delay = const Duration(milliseconds: 250),
    this.failLoading = false,
    this.failUpdate = false,
    NotificationPreferences? initialPreferences,
  }) : _preferences = initialPreferences ?? _defaults;

  final Duration delay;
  final bool failLoading;
  final bool failUpdate;
  NotificationPreferences _preferences;
  int updateCallCount = 0;

  static const NotificationPreferences _defaults = NotificationPreferences(
    claimStatusUpdates: true,
    aiAnalysisCompletion: true,
    additionalEvidenceRequests: true,
    claimDecisions: true,
    paymentUpdates: true,
    policyExpiryReminders: true,
    securityAlerts: true,
    promotionalNotifications: false,
  );

  @override
  Future<NotificationPreferences> getPreferences() async {
    await _wait();
    if (failLoading) {
      throw StateError('Unable to load notification preferences.');
    }
    return _preferences;
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    updateCallCount++;
    await _wait();
    if (failUpdate) {
      throw StateError('Unable to update notification preferences.');
    }
    _preferences = preferences;
    return _preferences;
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
