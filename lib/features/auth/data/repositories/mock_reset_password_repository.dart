import '../../domain/entities/reset_password_request.dart';
import '../../domain/repositories/reset_password_repository.dart';

class MockResetPasswordRepository implements ResetPasswordRepository {
  const MockResetPasswordRepository();

  @override
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    return request.resetToken.trim().isNotEmpty &&
        request.newPassword.length >= 8 &&
        request.newPassword == request.confirmPassword;
  }
}
