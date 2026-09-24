import '../entities/otp_verification_request.dart';
import '../entities/password_reset_session.dart';

abstract interface class OtpVerificationRepository {
  Future<PasswordResetSession?> verifyOtp(OtpVerificationRequest request);

  Future<bool> resendOtp({required String identity});
}
