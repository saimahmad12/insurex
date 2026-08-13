import '../entities/forgot_password_request.dart';

abstract interface class PasswordRecoveryRepository {
  Future<bool> requestPasswordReset(
      ForgotPasswordRequest request,
      );
}