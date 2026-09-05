import '../../domain/entities/account_role.dart';
import '../../domain/entities/seller_authentication.dart';
import '../../domain/entities/seller_registration.dart';
import '../../domain/repositories/seller_auth_repository.dart';

class MockSellerAccountRecord {
  const MockSellerAccountRecord({
    required this.companyName,
    required this.password,
    required this.authoritativeRole,
    required this.registrationStatus,
  });

  final String companyName;
  final String password;
  final AccountRole authoritativeRole;
  final SellerRegistrationStatus registrationStatus;
}

class MockSellerAuthRepository implements SellerAuthRepository {
  MockSellerAuthRepository({
    Map<String, MockSellerAccountRecord>? accounts,
    Set<String>? technicalFailureEmails,
    this.delay = const Duration(milliseconds: 750),
  }) : accounts = accounts ?? defaultAccounts,
       technicalFailureEmails =
           technicalFailureEmails ?? const <String>{'technical@insurex.test'};

  static const String demoPassword = 'SellerPass1';

  static const Map<String, MockSellerAccountRecord> defaultAccounts =
      <String, MockSellerAccountRecord>{
        'approved@insurex.test': MockSellerAccountRecord(
          companyName: 'Approved Assurance Ltd',
          password: demoPassword,
          authoritativeRole: AccountRole.seller,
          registrationStatus: SellerRegistrationStatus.approved,
        ),
        'pending@insurex.test': MockSellerAccountRecord(
          companyName: 'Pending Protection Ltd',
          password: demoPassword,
          authoritativeRole: AccountRole.seller,
          registrationStatus: SellerRegistrationStatus.pendingApproval,
        ),
        'rejected@insurex.test': MockSellerAccountRecord(
          companyName: 'Rejected Risk Ltd',
          password: demoPassword,
          authoritativeRole: AccountRole.seller,
          registrationStatus: SellerRegistrationStatus.rejected,
        ),
        'suspended@insurex.test': MockSellerAccountRecord(
          companyName: 'Suspended Security Ltd',
          password: demoPassword,
          authoritativeRole: AccountRole.seller,
          registrationStatus: SellerRegistrationStatus.suspended,
        ),
        'customer@insurex.test': MockSellerAccountRecord(
          companyName: 'Customer Account',
          password: demoPassword,
          authoritativeRole: AccountRole.customer,
          registrationStatus: SellerRegistrationStatus.approved,
        ),
      };

  final Map<String, MockSellerAccountRecord> accounts;
  final Set<String> technicalFailureEmails;
  final Duration delay;

  int loginCallCount = 0;
  SellerLoginCredentials? lastCredentials;

  @override
  Future<SellerAuthenticationResult> login(
    SellerLoginCredentials credentials,
  ) async {
    loginCallCount++;
    lastCredentials = credentials;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final String email = credentials.businessEmail.trim().toLowerCase();
    if (technicalFailureEmails.contains(email)) {
      return const SellerAuthenticationResult.failed(
        SellerAuthenticationFailure.technicalFailure,
      );
    }

    final MockSellerAccountRecord? record = accounts[email];
    if (record == null || record.password != credentials.password) {
      return const SellerAuthenticationResult.failed(
        SellerAuthenticationFailure.invalidCredentials,
      );
    }

    return SellerAuthenticationResult.authenticated(
      SellerAccount(
        companyName: record.companyName,
        businessEmail: email,
        authoritativeRole: record.authoritativeRole,
        registrationStatus: record.registrationStatus,
      ),
    );
  }
}
