import '../entities/security_settings.dart';

abstract interface class SecurityRepository {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<SecuritySettings> getSecuritySettings();

  Future<SecuritySettings> updateSecuritySettings(SecuritySettings settings);
}
