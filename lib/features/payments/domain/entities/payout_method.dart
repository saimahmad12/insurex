enum PayoutMethodType { bankTransfer, easypaisa, jazzCash }

enum PayoutMethodVerificationStatus {
  unverified,
  verificationPending,
  verified,
  failed,
}

class PayoutMethod {
  const PayoutMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.accountHolderName,
    required this.maskedAccount,
    required this.verificationStatus,
  });

  final String id;
  final PayoutMethodType type;
  final String displayName;
  final String accountHolderName;
  final String maskedAccount;
  final PayoutMethodVerificationStatus verificationStatus;

  bool get isVerified =>
      verificationStatus == PayoutMethodVerificationStatus.verified;

  PayoutMethod copyWith({PayoutMethodVerificationStatus? verificationStatus}) {
    return PayoutMethod(
      id: id,
      type: type,
      displayName: displayName,
      accountHolderName: accountHolderName,
      maskedAccount: maskedAccount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class PayoutMethodRequest {
  const PayoutMethodRequest({
    required this.type,
    required this.accountHolderName,
    required this.destination,
    this.bankName,
    this.branchInformation,
  });

  final PayoutMethodType type;
  final String accountHolderName;
  final String destination;
  final String? bankName;
  final String? branchInformation;
}

String maskBankAccount(String value) {
  final String compact = value.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  final String lastFour = compact.length <= 4
      ? compact.padLeft(4, '*')
      : compact.substring(compact.length - 4);
  return '**** **** **** $lastFour';
}

String maskPakistaniMobile(String value) {
  String digits = value.replaceAll(RegExp('[^0-9]'), '');
  if (digits.startsWith('92') && digits.length >= 12) {
    digits = '0${digits.substring(2)}';
  }
  final String lastFour = digits.length <= 4
      ? digits.padLeft(4, '*')
      : digits.substring(digits.length - 4);
  return '03** *** $lastFour';
}
