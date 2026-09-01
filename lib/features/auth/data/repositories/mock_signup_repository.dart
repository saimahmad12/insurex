import '../../domain/entities/signup_request.dart';
import '../../domain/repositories/signup_repository.dart';

class MockSignupRepository implements SignupRepository {
  MockSignupRepository({
    required this.initializeAccountName,
    this.delay = const Duration(milliseconds: 1400),
  });

  final Future<void> Function(String fullName) initializeAccountName;
  final Duration delay;
  int prepareCallCount = 0;
  int completeCallCount = 0;
  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;

  @override
  Future<bool> prepareSignup(SignupRequest request) async {
    prepareCallCount++;
    await _wait();

    final bool valid = _isValid(request);
    if (valid) {
      await initializeAccountName(request.fullName);
    }
    return valid;
  }

  @override
  Future<bool> completeSignup(SignupRequest request) async {
    if (_isCompleted) {
      return true;
    }
    completeCallCount++;
    await _wait();
    if (!_isValid(request)) {
      return false;
    }
    _isCompleted = true;
    return true;
  }

  bool _isValid(SignupRequest request) {
    final bool hasFullName = request.fullName.trim().isNotEmpty;
    final bool hasEmail = request.email.trim().isNotEmpty;
    final bool hasMobileNumber = request.mobileNumber.trim().isNotEmpty;
    final bool hasValidPassword = request.password.length >= 8;
    return hasFullName && hasEmail && hasMobileNumber && hasValidPassword;
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
