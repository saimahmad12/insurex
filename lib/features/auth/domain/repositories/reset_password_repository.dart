import '../entities/reset_password_request.dart';

abstract interface class ResetPasswordRepository {
  Future<bool> resetPassword(
      ResetPasswordRequest request,
      );
}