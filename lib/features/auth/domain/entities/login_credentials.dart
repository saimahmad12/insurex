import 'account_role.dart';

class LoginCredentials {
  const LoginCredentials({
    required this.identity,
    required this.password,
    required this.role,
  });

  final String identity;
  final String password;
  final AccountRole role;
}
