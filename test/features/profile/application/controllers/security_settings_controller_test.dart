import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/security_settings_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_security_repository.dart';

void main() {
  group('SecuritySettingsController', () {
    test('loads settings and updates biometric preference', () async {
      final MockSecurityRepository repository = MockSecurityRepository(
        delay: Duration.zero,
      );
      final SecuritySettingsController controller = _controller(repository);

      await controller.initialize();
      expect(controller.settings?.biometricLoginEnabled, isFalse);
      expect(await controller.updateBiometricLogin(true), isTrue);
      expect(controller.settings?.biometricLoginEnabled, isTrue);
      expect(repository.settingsUpdateCallCount, 1);
      expect(await controller.updateBiometricLogin(true), isFalse);
      expect(repository.settingsUpdateCallCount, 1);
    });

    test('failed biometric update restores previous value', () async {
      final SecuritySettingsController controller = _controller(
        MockSecurityRepository(delay: Duration.zero, failSettingsUpdate: true),
      );
      await controller.initialize();

      expect(await controller.updateBiometricLogin(true), isFalse);
      expect(controller.settings?.biometricLoginEnabled, isFalse);
      expect(
        controller.settingUpdateStatus,
        SecuritySettingUpdateStatus.failure,
      );
    });

    test('changes password and rejects duplicate request', () async {
      final MockSecurityRepository repository = MockSecurityRepository(
        delay: const Duration(milliseconds: 10),
      );
      final SecuritySettingsController controller = _controller(repository);

      final Future<bool> first = controller.changePassword(
        currentPassword: 'Current@123',
        newPassword: 'NewSecure1',
        confirmPassword: 'NewSecure1',
      );
      final Future<bool> duplicate = controller.changePassword(
        currentPassword: 'Current@123',
        newPassword: 'NewSecure1',
        confirmPassword: 'NewSecure1',
      );

      expect(controller.isChangingPassword, isTrue);
      expect(await duplicate, isFalse);
      expect(await first, isTrue);
      expect(repository.passwordChangeCallCount, 1);
    });

    test('password validation and repository failure are distinct', () async {
      final MockSecurityRepository repository = MockSecurityRepository(
        delay: Duration.zero,
        failPasswordChange: true,
      );
      final SecuritySettingsController controller = _controller(repository);

      expect(
        await controller.changePassword(
          currentPassword: '',
          newPassword: 'weak',
          confirmPassword: 'different',
        ),
        isFalse,
      );
      expect(controller.passwordValidationErrors, isNotEmpty);
      expect(repository.passwordChangeCallCount, 0);

      expect(
        await controller.changePassword(
          currentPassword: 'Current@123',
          newPassword: 'NewSecure1',
          confirmPassword: 'NewSecure1',
        ),
        isFalse,
      );
      expect(controller.passwordChangeStatus, PasswordChangeStatus.failure);
      expect(repository.passwordChangeCallCount, 1);
    });
  });
}

SecuritySettingsController _controller(MockSecurityRepository repository) {
  return SecuritySettingsController(
    repository: repository,
    authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
  );
}
