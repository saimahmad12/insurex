import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/validators/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    test('requires a strong new password', () {
      expect(PasswordValidator.validateNewPassword('Secure123'), isNull);
      expect(PasswordValidator.validateNewPassword('short'), isNotNull);
      expect(PasswordValidator.validateNewPassword('lowercase1'), isNotNull);
      expect(PasswordValidator.validateNewPassword('NOLOWER1'), isNotNull);
      expect(PasswordValidator.validateNewPassword('NoNumber'), isNotNull);
    });

    test('requires matching confirmation', () {
      expect(
        PasswordValidator.validateConfirmation('Secure123', 'Secure123'),
        isNull,
      );
      expect(
        PasswordValidator.validateConfirmation('Different1', 'Secure123'),
        isNotNull,
      );
    });
  });
}
