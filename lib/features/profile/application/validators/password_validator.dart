abstract final class PasswordValidator {
  static String? validateCurrentPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Enter your current password.';
    }
    return null;
  }

  static String? validateNewPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Enter a new password.';
    }
    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }
    if (!RegExp('[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter.';
    }
    if (!RegExp('[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter.';
    }
    if (!RegExp('[0-9]').hasMatch(password)) {
      return 'Add at least one number.';
    }
    return null;
  }

  static String? validateConfirmation(String? value, String newPassword) {
    final String confirmation = value ?? '';
    if (confirmation.isEmpty) {
      return 'Confirm your new password.';
    }
    if (confirmation != newPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static Map<String, String> validate({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final Map<String, String> errors = <String, String>{};
    final String? currentError = validateCurrentPassword(currentPassword);
    final String? newError = validateNewPassword(newPassword);
    final String? confirmError = validateConfirmation(
      confirmPassword,
      newPassword,
    );
    if (currentError != null) {
      errors['currentPassword'] = currentError;
    }
    if (newError != null) {
      errors['newPassword'] = newError;
    }
    if (confirmError != null) {
      errors['confirmPassword'] = confirmError;
    }
    return errors;
  }
}
