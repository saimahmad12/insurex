import '../entities/identity_verification.dart';

abstract interface class IdentityVerificationRepository {
  Future<IdentityVerification> getIdentityVerification();

  Future<IdentityVerification> startIdentityVerification();
}
