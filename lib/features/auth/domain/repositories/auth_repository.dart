import '../entities/login_credentials.dart';

abstract interface class AuthRepository {
  Future<bool> login(LoginCredentials credentials);
}