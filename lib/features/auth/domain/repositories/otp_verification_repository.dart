import '../entities/otp_verification_request.dart';

abstract interface class OtpVerificationRepository {
  Future<bool> verifyOtp(
      OtpVerificationRequest request,
      );

  Future<bool> resendOtp({
    required String identity,
  });
}