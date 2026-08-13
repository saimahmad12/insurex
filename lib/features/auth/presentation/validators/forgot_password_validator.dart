abstract final class ForgotPasswordValidator {
  static String? validateIdentity(String? value) {
    final String input = value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Enter your email or mobile number.';
    }

    if (input.contains('@')) {
      final RegExp emailPattern = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      );

      if (!emailPattern.hasMatch(input)) {
        return 'Enter a valid email address.';
      }

      return null;
    }

    final String digits = input.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid mobile number.';
    }

    return null;
  }
}