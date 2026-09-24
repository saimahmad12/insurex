class PasswordResetSession {
  const PasswordResetSession({
    required this.identity,
    required this.resetToken,
  });

  final String identity;
  final String resetToken;
}
