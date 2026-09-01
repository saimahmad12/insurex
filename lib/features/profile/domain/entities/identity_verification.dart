import 'identity_verification_draft.dart';

enum IdentityVerificationStatus {
  notStarted,
  capturing,
  submitted,
  pending,
  verified,
  rejected,
  expired,
  additionalCaptureRequired,
  technicalFailure,
}

class IdentityVerification {
  const IdentityVerification({
    required this.status,
    required this.maskedIdentityNumber,
    this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
    this.expiresAt,
    this.additionalCaptureSide,
    this.providerReference,
    this.proofRecordHash,
  });

  final IdentityVerificationStatus status;
  final String maskedIdentityNumber;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime? expiresAt;
  final IdentityCaptureSide? additionalCaptureSide;
  final String? providerReference;
  final String? proofRecordHash;

  IdentityVerification copyWith({
    IdentityVerificationStatus? status,
    String? maskedIdentityNumber,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime? expiresAt,
    IdentityCaptureSide? additionalCaptureSide,
    String? providerReference,
    String? proofRecordHash,
    bool clearVerifiedAt = false,
    bool clearRejectionReason = false,
  }) {
    return IdentityVerification(
      status: status ?? this.status,
      maskedIdentityNumber: maskedIdentityNumber ?? this.maskedIdentityNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: clearVerifiedAt ? null : verifiedAt ?? this.verifiedAt,
      rejectionReason: clearRejectionReason
          ? null
          : rejectionReason ?? this.rejectionReason,
      expiresAt: expiresAt ?? this.expiresAt,
      additionalCaptureSide:
          additionalCaptureSide ?? this.additionalCaptureSide,
      providerReference: providerReference ?? this.providerReference,
      proofRecordHash: proofRecordHash ?? this.proofRecordHash,
    );
  }
}
