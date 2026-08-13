class SignupRequest {
  const SignupRequest({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
  });

  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
}