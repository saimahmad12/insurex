abstract final class OtpValidator {
  static String? validate(String? value) {
    final String otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'Enter the verification code.';
    }

    if (otp.length != 6) {
      return 'Enter the complete 6-digit code.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must contain numbers only.';
    }

    return null;
  }
}