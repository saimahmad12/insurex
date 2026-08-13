import '../entities/signup_request.dart';

abstract interface class SignupRepository {
  Future<bool> signup(SignupRequest request);
}