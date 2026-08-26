import '../../domain/entities/payout_method.dart';

abstract final class PayoutMethodValidator {
  static String? validateAccountHolderName(String? value) {
    final String name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Enter the account holder name.';
    }
    if (!RegExp(r"^[A-Za-z][A-Za-z .'-]{2,}$").hasMatch(name)) {
      return 'Enter a valid account holder name.';
    }
    return null;
  }

  static String? validateBankName(String? value) {
    final String bankName = value?.trim() ?? '';
    if (bankName.isEmpty) {
      return 'Enter the bank name.';
    }
    if (bankName.length < 2) {
      return 'Enter a valid bank name.';
    }
    return null;
  }

  static String? validateBankDestination(String? value) {
    final String destination = (value ?? '')
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase();
    if (destination.isEmpty) {
      return 'Enter an IBAN or account number.';
    }
    final bool validIban = RegExp(
      r'^PK[0-9]{2}[A-Z0-9]{20}$',
    ).hasMatch(destination);
    final bool validAccount = RegExp(r'^[0-9]{10,24}$').hasMatch(destination);
    if (!validIban && !validAccount) {
      return 'Enter a valid IBAN or account number.';
    }
    return null;
  }

  static String? validatePakistaniMobile(String? value) {
    final String mobile = (value ?? '').replaceAll(RegExp('[^0-9+]'), '');
    if (mobile.isEmpty) {
      return 'Enter the registered mobile number.';
    }
    final bool valid = RegExp(r'^(?:\+92|92|0)3[0-9]{9}$').hasMatch(mobile);
    if (!valid) {
      return 'Enter a valid Pakistani mobile number.';
    }
    return null;
  }

  static Map<String, String> validate(PayoutMethodRequest request) {
    final Map<String, String> errors = <String, String>{};
    final String? holderError = validateAccountHolderName(
      request.accountHolderName,
    );
    if (holderError != null) {
      errors['accountHolderName'] = holderError;
    }

    if (request.type == PayoutMethodType.bankTransfer) {
      final String? bankError = validateBankName(request.bankName);
      if (bankError != null) {
        errors['bankName'] = bankError;
      }
      final String? destinationError = validateBankDestination(
        request.destination,
      );
      if (destinationError != null) {
        errors['destination'] = destinationError;
      }
    } else {
      final String? destinationError = validatePakistaniMobile(
        request.destination,
      );
      if (destinationError != null) {
        errors['destination'] = destinationError;
      }
    }
    return errors;
  }
}
