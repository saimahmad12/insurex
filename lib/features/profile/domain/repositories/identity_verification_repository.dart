import '../entities/identity_verification.dart';
import '../entities/identity_verification_draft.dart';

abstract interface class IdentityVerificationRepository {
  Future<String> getCanonicalAccountName();

  Future<IdentityVerification> getIdentityVerification();

  Future<IdentityVerification> startIdentityVerification();

  Future<IdentityVerificationProgress?> getVerificationProgress();

  Future<void> saveVerificationProgress(IdentityVerificationProgress progress);

  Future<void> clearVerificationProgress();

  Future<IdentityUploadSession> createUploadSession();

  Future<IdentityCaptureEvidence> registerCapture(
    IdentityUploadSession session,
    IdentityCaptureInput capture,
  );

  Future<void> discardCapture(String captureId);

  Future<IdentityVerification> submitIdentityVerification(
    IdentityVerificationSubmission submission,
  );

  Future<void> cancelIdentityVerification();
}
