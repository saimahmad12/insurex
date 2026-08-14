abstract final class ResetPasswordValidator {
  static String? validatePassword(
      String? value,
      ) {
    final String password = value ?? '';

    if (password.isEmpty) {
      return 'Enter a new password.';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Add at least one number.';
    }

    return null;
  }

  static String? validateConfirmPassword({
    required String? value,
    required String password,
  }) {
    final String confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm your new password.';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  static bool hasMinimumLength(
      String password,
      ) {
    return password.length >= 8;
  }

  static bool hasUppercase(
      String password,
      ) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  static bool hasLowercase(
      String password,
      ) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  static bool hasNumber(
      String password,
      ) {
    return RegExp(r'[0-9]').hasMatch(password);
  }
}