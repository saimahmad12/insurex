import '../../domain/entities/forgot_password_request.dart';
import '../../domain/repositories/password_recovery_repository.dart';

class MockPasswordRecoveryRepository
    implements PasswordRecoveryRepository {
  const MockPasswordRecoveryRepository();

  @override
  Future<bool> requestPasswordReset(
      ForgotPasswordRequest request,
      ) async {
    // Temporary delay to simulate a backend API request.
    await Future<void>.delayed(
      const Duration(milliseconds: 1300),
    );

    return request.identity.trim().isNotEmpty;
  }
}