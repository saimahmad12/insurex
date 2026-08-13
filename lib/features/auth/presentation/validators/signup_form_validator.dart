abstract final class SignupFormValidator {
  static String? validateFullName(String? value) {
    final String fullName = value?.trim() ?? '';

    if (fullName.isEmpty) {
      return 'Enter your full name.';
    }

    if (fullName.length < 3) {
      return 'Full name must contain at least 3 characters.';
    }

    if (!RegExp(r"^[a-zA-Z\s.'-]+$").hasMatch(fullName)) {
      return 'Enter a valid full name.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email address.';
    }

    final RegExp emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? validateMobileNumber(String? value) {
    final String mobileNumber = value?.trim() ?? '';

    if (mobileNumber.isEmpty) {
      return 'Enter your mobile number.';
    }

    final String digits = mobileNumber.replaceAll(
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

  static String? validateConfirmPassword(
      String? value,
      String password,
      ) {
    final String confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm your password.';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
}