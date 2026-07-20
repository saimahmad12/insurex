import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<bool> login(LoginCredentials credentials) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 1200),
    );

    final bool hasValidIdentity =
        credentials.identity.trim().isNotEmpty;

    final bool hasValidPassword =
        credentials.password.length >= 6;

    return hasValidIdentity && hasValidPassword;
  }
}