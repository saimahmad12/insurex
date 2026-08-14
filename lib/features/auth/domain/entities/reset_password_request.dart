class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.identity,
    required this.newPassword,
  });

  final String identity;
  final String newPassword;
}