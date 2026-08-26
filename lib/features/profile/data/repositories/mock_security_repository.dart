import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/security_repository.dart';

class MockSecurityRepository implements SecurityRepository {
  MockSecurityRepository({
    this.delay = const Duration(milliseconds: 300),
    this.failLoading = false,
    this.failSettingsUpdate = false,
    this.failPasswordChange = false,
    SecuritySettings? initialSettings,
  }) : _settings = initialSettings ?? _defaults;

  final Duration delay;
  final bool failLoading;
  final bool failSettingsUpdate;
  final bool failPasswordChange;
  SecuritySettings _settings;
  int passwordChangeCallCount = 0;
  int settingsUpdateCallCount = 0;

  static const SecuritySettings _defaults = SecuritySettings(
    biometricLoginEnabled: false,
    twoFactorAuthenticationAvailable: false,
    twoFactorAuthenticationEnabled: false,
    activeSessionDescription: 'Current device • Islamabad, Pakistan',
  );

  @override
  Future<SecuritySettings> getSecuritySettings() async {
    await _wait();
    if (failLoading) {
      throw StateError('Unable to load security settings.');
    }
    return _settings;
  }

  @override
  Future<SecuritySettings> updateSecuritySettings(
    SecuritySettings settings,
  ) async {
    settingsUpdateCallCount++;
    await _wait();
    if (failSettingsUpdate) {
      throw StateError('Unable to update security settings.');
    }
    _settings = settings;
    return _settings;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    passwordChangeCallCount++;
    await _wait();
    if (failPasswordChange ||
        currentPassword.isEmpty ||
        newPassword.length < 8) {
      throw StateError('Unable to change password.');
    }
    // Mock success only. Raw passwords are never retained or logged.
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
