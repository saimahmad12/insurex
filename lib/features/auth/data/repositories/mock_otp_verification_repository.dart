import '../../domain/entities/otp_verification_request.dart';
import '../../domain/entities/password_reset_session.dart';
import '../../domain/repositories/otp_verification_repository.dart';

class MockOtpVerificationRepository implements OtpVerificationRepository {
  const MockOtpVerificationRepository();

  @override
  Future<PasswordResetSession?> verifyOtp(
    OtpVerificationRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (request.code != '123456') {
      return null;
    }

    return PasswordResetSession(
      identity: request.identity.trim(),
      resetToken: 'mock-reset-token',
    );
  }

  @override
  Future<bool> resendOtp({required String identity}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return identity.trim().isNotEmpty;
  }
}
