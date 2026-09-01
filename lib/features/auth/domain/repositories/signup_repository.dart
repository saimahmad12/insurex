import '../entities/signup_request.dart';

abstract interface class SignupRepository {
  Future<bool> prepareSignup(SignupRequest request);

  Future<bool> completeSignup(SignupRequest request);
}
