import '../../domain/entities/identity_verification_draft.dart';
import '../validators/profile_validator.dart';

abstract final class IdentityVerificationValidator {
  static const int cnicDigitCount = 13;

  static String normalizeCnicDigits(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\D'), '');
  }

  static String formatCnic(String? value) {
    final String normalized = normalizeCnicDigits(value);
    final String digits = normalized.length > cnicDigitCount
        ? normalized.substring(0, cnicDigitCount)
        : normalized;
    if (digits.length <= 5) {
      return digits;
    }
    if (digits.length <= 12) {
      return '${digits.substring(0, 5)}-${digits.substring(5)}';
    }
    return '${digits.substring(0, 5)}-'
        '${digits.substring(5, 12)}-${digits.substring(12)}';
  }

  static String? validateCnic(String? value) {
    final String digits = normalizeCnicDigits(value);
    if (digits.length != cnicDigitCount) {
      return 'Enter CNIC in the required format.';
    }
    final String cnic = formatCnic(digits);
    if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(cnic)) {
      return 'Enter CNIC in the required format.';
    }
    return null;
  }

  static String? validateExpiryDate(DateTime? value, {DateTime? today}) {
    if (value == null) {
      return 'Select the CNIC expiry date.';
    }
    final DateTime reference = today ?? DateTime.now();
    final DateTime currentDate = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    if (!value.isAfter(currentDate)) {
      return 'CNIC must not be expired.';
    }
    return null;
  }

  static Map<String, String> validateLegalDetails(
    IdentityLegalDetails details,
  ) {
    final Map<String, String> errors = <String, String>{};
    void add(String key, String? error) {
      if (error != null) {
        errors[key] = error;
      }
    }

    add(
      'fullLegalName',
      ProfileValidator.validateFullName(details.fullLegalName),
    );
    add('cnicNumber', validateCnic(details.cnicNumber));
    add(
      'dateOfBirth',
      ProfileValidator.validateDateOfBirth(details.dateOfBirth),
    );
    add('cnicExpiryDate', validateExpiryDate(details.cnicExpiryDate));
    return errors;
  }
}
