import '../../domain/entities/signup_request.dart';
import '../../domain/repositories/signup_repository.dart';

class MockSignupRepository implements SignupRepository {
  const MockSignupRepository();

  @override
  Future<bool> signup(SignupRequest request) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 1400),
    );

    final bool hasFullName =
        request.fullName.trim().isNotEmpty;

    final bool hasEmail =
        request.email.trim().isNotEmpty;

    final bool hasMobileNumber =
        request.mobileNumber.trim().isNotEmpty;

    final bool hasValidPassword =
        request.password.length >= 8;

    return hasFullName &&
        hasEmail &&
        hasMobileNumber &&
        hasValidPassword;
  }
}