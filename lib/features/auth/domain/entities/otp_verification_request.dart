class OtpVerificationRequest {
  const OtpVerificationRequest({
    required this.identity,
    required this.code,
  });

  final String identity;
  final String code;
}