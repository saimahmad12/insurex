import '../../domain/entities/profile_update_request.dart';

abstract final class ProfileValidator {
  static String? validateFullName(String? value) {
    final String name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Enter your full name.';
    }
    if (name.length < 3 || !RegExp(r"^[A-Za-z][A-Za-z .'-]+$").hasMatch(name)) {
      return 'Enter a valid full name.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Enter your email address.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validatePakistaniMobile(String? value) {
    final String mobile = (value ?? '').replaceAll(RegExp('[^0-9+]'), '');
    if (mobile.isEmpty) {
      return 'Enter your mobile number.';
    }
    if (!RegExp(r'^(?:\+92|92|0)3[0-9]{9}$').hasMatch(mobile)) {
      return 'Enter a valid Pakistani mobile number.';
    }
    return null;
  }

  static String? validateDateOfBirth(DateTime? value, {DateTime? today}) {
    if (value == null) {
      return 'Select your date of birth.';
    }
    final DateTime reference = today ?? DateTime.now();
    final DateTime currentDate = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime birthDate = DateTime(value.year, value.month, value.day);
    if (birthDate.isAfter(currentDate)) {
      return 'Date of birth cannot be in the future.';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    final String address = value?.trim() ?? '';
    if (address.length < 5) {
      return 'Enter your residential address.';
    }
    return null;
  }

  static String? validateRequiredLocation(String? value, String label) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter your $label.';
    }
    return null;
  }

  static Map<String, String> validate(ProfileUpdateRequest request) {
    final Map<String, String> errors = <String, String>{};
    void add(String key, String? error) {
      if (error != null) {
        errors[key] = error;
      }
    }

    if (request.fullName != null) {
      add('fullName', validateFullName(request.fullName));
    }
    if (request.dateOfBirth != null) {
      add('dateOfBirth', validateDateOfBirth(request.dateOfBirth));
    }
    add('address', validateAddress(request.address.residentialAddress));
    add('city', validateRequiredLocation(request.address.city, 'city'));
    add(
      'country',
      validateRequiredLocation(request.address.country, 'country'),
    );
    return errors;
  }
}
