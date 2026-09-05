import '../../domain/entities/seller_registration.dart';

enum SellerRegistrationField {
  registeredCompanyName,
  businessEmail,
  businessPhoneNumber,
  companyRegistrationNumber,
  insuranceLicenseNumber,
  officeAddress,
  authorizedRepresentativeName,
  authorizedRepresentativeDesignation,
  supportedCategories,
  password,
  confirmPassword,
  terms,
  declarations,
}

enum SellerLoginField { businessEmail, password }

class SellerAuthValidator {
  const SellerAuthValidator();

  Map<SellerRegistrationField, String> validateRegistration({
    required String registeredCompanyName,
    required String businessEmail,
    required String businessPhoneNumber,
    required String companyRegistrationNumber,
    required String insuranceLicenseNumber,
    required String officeAddress,
    required String authorizedRepresentativeName,
    required RepresentativeDesignation? authorizedRepresentativeDesignation,
    required Set<InsuranceCategory> supportedCategories,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
    required bool confirmedDeclarations,
  }) {
    final Map<SellerRegistrationField, String> errors =
        <SellerRegistrationField, String>{};

    _addIfInvalid(
      errors,
      SellerRegistrationField.registeredCompanyName,
      _validateRequiredName(
        registeredCompanyName,
        emptyMessage: 'Enter the registered company name.',
        invalidMessage: 'Enter a valid registered company name.',
      ),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.businessEmail,
      _validateEmail(businessEmail),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.businessPhoneNumber,
      _validatePhone(businessPhoneNumber),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.companyRegistrationNumber,
      _validateReference(
        companyRegistrationNumber,
        emptyMessage: 'Enter the company registration number.',
        invalidMessage: 'Enter a valid company registration number.',
      ),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.insuranceLicenseNumber,
      _validateReference(
        insuranceLicenseNumber,
        emptyMessage: 'Enter the insurance license number.',
        invalidMessage: 'Enter a valid insurance license number.',
      ),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.officeAddress,
      _validateAddress(officeAddress),
    );
    _addIfInvalid(
      errors,
      SellerRegistrationField.authorizedRepresentativeName,
      _validateRequiredName(
        authorizedRepresentativeName,
        emptyMessage: 'Enter the authorized representative name.',
        invalidMessage: 'Enter a valid representative name.',
      ),
    );
    if (authorizedRepresentativeDesignation == null) {
      errors[SellerRegistrationField.authorizedRepresentativeDesignation] =
          'Select the representative designation.';
    }
    if (supportedCategories.isEmpty) {
      errors[SellerRegistrationField.supportedCategories] =
          'Select at least one insurance category.';
    }
    _addIfInvalid(
      errors,
      SellerRegistrationField.password,
      _validatePassword(password),
    );
    if (confirmPassword.isEmpty) {
      errors[SellerRegistrationField.confirmPassword] =
          'Confirm your password.';
    } else if (confirmPassword != password) {
      errors[SellerRegistrationField.confirmPassword] =
          'Passwords do not match.';
    }
    if (!acceptedTerms) {
      errors[SellerRegistrationField.terms] =
          'You must accept the terms to continue.';
    }
    if (!confirmedDeclarations) {
      errors[SellerRegistrationField.declarations] =
          'Confirm that the company information is accurate.';
    }

    return errors;
  }

  Map<SellerLoginField, String> validateLogin({
    required String businessEmail,
    required String password,
  }) {
    final Map<SellerLoginField, String> errors = <SellerLoginField, String>{};
    _addIfInvalid(
      errors,
      SellerLoginField.businessEmail,
      _validateEmail(businessEmail),
    );
    if (password.isEmpty) {
      errors[SellerLoginField.password] = 'Enter your password.';
    } else if (password.length < 6) {
      errors[SellerLoginField.password] =
          'Password must contain at least 6 characters.';
    }
    return errors;
  }

  static void _addIfInvalid<T>(Map<T, String> errors, T field, String? error) {
    if (error != null) {
      errors[field] = error;
    }
  }

  static String? _validateRequiredName(
    String value, {
    required String emptyMessage,
    required String invalidMessage,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return emptyMessage;
    }
    if (trimmed.length < 3 ||
        !RegExp(r"^[a-zA-Z0-9&.,()'\-\s]+$").hasMatch(trimmed)) {
      return invalidMessage;
    }
    return null;
  }

  static String? _validateEmail(String value) {
    final String email = value.trim();
    if (email.isEmpty) {
      return 'Enter the business email.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid business email.';
    }
    return null;
  }

  static String? _validatePhone(String value) {
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.trim().isEmpty) {
      return 'Enter the business phone number.';
    }
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid business phone number.';
    }
    return null;
  }

  static String? _validateReference(
    String value, {
    required String emptyMessage,
    required String invalidMessage,
  }) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return emptyMessage;
    }
    if (trimmed.length < 4 ||
        !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9./\-\s]+$').hasMatch(trimmed)) {
      return invalidMessage;
    }
    return null;
  }

  static String? _validateAddress(String value) {
    final String address = value.trim();
    if (address.isEmpty) {
      return 'Enter the registered office address.';
    }
    if (address.length < 8) {
      return 'Office address must contain at least 8 characters.';
    }
    return null;
  }

  static String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Enter your password.';
    }
    if (value.length < 8) {
      return 'Password must contain at least 8 characters.';
    }
    if (!RegExp('[A-Z]').hasMatch(value)) {
      return 'Add at least one uppercase letter.';
    }
    if (!RegExp('[a-z]').hasMatch(value)) {
      return 'Add at least one lowercase letter.';
    }
    if (!RegExp('[0-9]').hasMatch(value)) {
      return 'Add at least one number.';
    }
    return null;
  }
}
