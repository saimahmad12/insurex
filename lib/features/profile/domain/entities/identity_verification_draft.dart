import 'profile_gender.dart';

enum IdentityCaptureSide { front, back, selfie }

class IdentityCaptureQuality {
  const IdentityCaptureQuality({
    required this.width,
    required this.height,
    required this.fileSizeBytes,
    required this.averageLuminance,
    required this.sharpnessScore,
  });

  final int width;
  final int height;
  final int fileSizeBytes;
  final double averageLuminance;
  final double sharpnessScore;

  List<String> get issues {
    final List<String> result = <String>[];
    if (width < 1200 || height < 700) {
      result.add('Use a higher-resolution camera capture.');
    }
    if (fileSizeBytes < 50000) {
      result.add('The captured image is too small.');
    }
    if (fileSizeBytes > 12 * 1024 * 1024) {
      result.add('The captured image exceeds the secure upload size limit.');
    }
    if (width <= height && width > 0 && height > 0) {
      result.add('Hold the CNIC horizontally inside the frame.');
    }
    if (averageLuminance > 0 && averageLuminance < 35) {
      result.add('The image appears too dark.');
    }
    if (averageLuminance > 230) {
      result.add('The image appears overexposed or affected by glare.');
    }
    if (sharpnessScore > 0 && sharpnessScore < 6) {
      result.add('The image may be blurred. Hold the device steady.');
    }
    return List<String>.unmodifiable(result);
  }

  bool get passesFrontendChecks => issues.isEmpty;
}

class IdentityCaptureInput {
  const IdentityCaptureInput({
    required this.side,
    required this.temporaryPath,
    required this.fingerprint,
    required this.quality,
  });

  final IdentityCaptureSide side;

  /// An ephemeral private path used only by the capture/upload repository.
  final String temporaryPath;
  final String fingerprint;
  final IdentityCaptureQuality quality;
}

class IdentityCaptureEvidence {
  const IdentityCaptureEvidence({
    required this.captureId,
    required this.side,
    required this.fingerprint,
    required this.quality,
  });

  final String captureId;
  final IdentityCaptureSide side;
  final String fingerprint;
  final IdentityCaptureQuality quality;
}

class IdentityLegalDetails {
  const IdentityLegalDetails({
    required this.fullLegalName,
    required this.cnicNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.cnicExpiryDate,
  });

  /// Kept only in memory during verification and never used in route arguments.
  final String fullLegalName;
  final String cnicNumber;
  final DateTime dateOfBirth;
  final ProfileGender gender;
  final DateTime cnicExpiryDate;
}

class IdentityUploadSession {
  const IdentityUploadSession({
    required this.sessionId,
    required this.expiresAt,
  });

  final String sessionId;
  final DateTime expiresAt;
}

class IdentityVerificationSubmission {
  const IdentityVerificationSubmission({
    required this.uploadSession,
    required this.legalDetails,
    required this.front,
    required this.back,
    required this.selfie,
    required this.consentConfirmed,
    required this.accountNameChangeConfirmed,
  });

  final IdentityUploadSession uploadSession;
  final IdentityLegalDetails legalDetails;
  final IdentityCaptureEvidence front;
  final IdentityCaptureEvidence back;
  final IdentityCaptureEvidence selfie;
  final bool consentConfirmed;
  final bool accountNameChangeConfirmed;
}

/// In-memory resume state. Raw legal details must never be serialized, logged,
/// placed in route arguments, or written to shared/public storage.
class IdentityVerificationProgress {
  const IdentityVerificationProgress({
    required this.consentConfirmed,
    this.nameChangeConfirmed = false,
    this.legalDetails,
    this.front,
    this.back,
    this.selfie,
  });

  final bool consentConfirmed;
  final bool nameChangeConfirmed;
  final IdentityLegalDetails? legalDetails;
  final IdentityCaptureEvidence? front;
  final IdentityCaptureEvidence? back;
  final IdentityCaptureEvidence? selfie;
}
