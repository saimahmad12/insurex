abstract final class LoginFormValidator {
  static String? validateIdentity(String? value) {
    final String input = value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Enter your mobile number or email.';
    }

    final bool looksLikeEmail = input.contains('@');

    if (looksLikeEmail) {
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

  static String? validatePassword(String? value) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Enter your password.';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    return null;
  }
}