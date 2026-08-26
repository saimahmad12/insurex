import '../../domain/repositories/auth_session_repository.dart';

class MockAuthSessionRepository implements AuthSessionRepository {
  MockAuthSessionRepository({
    this.delay = const Duration(milliseconds: 300),
    this.failLogout = false,
  });

  final Duration delay;
  final bool failLogout;
  bool _sessionActive = true;
  bool get sessionActive => _sessionActive;
  int logoutCallCount = 0;

  @override
  Future<void> logout() async {
    logoutCallCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failLogout) {
      throw StateError('Unable to log out.');
    }
    _sessionActive = false;
  }
}
