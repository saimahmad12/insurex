import 'account_role.dart';
import 'seller_registration.dart';

class SellerLoginCredentials {
  const SellerLoginCredentials({
    required this.businessEmail,
    required this.password,
  });

  final String businessEmail;
  final String password;
}

class SellerAccount {
  const SellerAccount({
    required this.companyName,
    required this.businessEmail,
    required this.authoritativeRole,
    required this.registrationStatus,
  });

  final String companyName;
  final String businessEmail;
  final AccountRole authoritativeRole;
  final SellerRegistrationStatus registrationStatus;
}

enum SellerAuthenticationFailure { invalidCredentials, technicalFailure }

class SellerAuthenticationResult {
  const SellerAuthenticationResult.authenticated(this.account) : failure = null;

  const SellerAuthenticationResult.failed(this.failure) : account = null;

  final SellerAccount? account;
  final SellerAuthenticationFailure? failure;

  bool get isAuthenticated => account != null && failure == null;
}
