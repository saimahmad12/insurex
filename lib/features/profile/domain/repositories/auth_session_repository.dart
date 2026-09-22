abstract interface class AuthSessionRepository {
  Future<bool> restoreSession();

  Future<void> logout();
}