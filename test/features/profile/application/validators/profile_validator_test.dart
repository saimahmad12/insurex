import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/validators/profile_validator.dart';

void main() {
  group('ProfileValidator', () {
    test('validates a full name', () {
      expect(ProfileValidator.validateFullName(''), isNotNull);
      expect(ProfileValidator.validateFullName('A'), isNotNull);
      expect(ProfileValidator.validateFullName('Saim'), isNull);
      expect(ProfileValidator.validateFullName('Saim Ahmad'), isNull);
    });

    test('validates email format', () {
      expect(ProfileValidator.validateEmail('ayesha@example.com'), isNull);
      expect(ProfileValidator.validateEmail('invalid-email'), isNotNull);
    });

    test('validates Pakistani mobile numbers', () {
      expect(ProfileValidator.validatePakistaniMobile('03001234567'), isNull);
      expect(ProfileValidator.validatePakistaniMobile('+923001234567'), isNull);
      expect(ProfileValidator.validatePakistaniMobile('03123'), isNotNull);
    });

    test('rejects future dates of birth', () {
      final DateTime today = DateTime(2026, 8, 26);
      expect(
        ProfileValidator.validateDateOfBirth(
          DateTime(1993, 5, 18),
          today: today,
        ),
        isNull,
      );
      expect(
        ProfileValidator.validateDateOfBirth(
          DateTime(2026, 8, 27),
          today: today,
        ),
        isNotNull,
      );
    });
  });
}
