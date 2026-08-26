enum IdentityVerificationStatus { notStarted, pending, verified, rejected }

class IdentityVerification {
  const IdentityVerification({
    required this.status,
    required this.maskedIdentityNumber,
    this.submittedAt,
    this.verifiedAt,
    this.rejectionReason,
  });

  final IdentityVerificationStatus status;
  final String maskedIdentityNumber;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  IdentityVerification copyWith({
    IdentityVerificationStatus? status,
    String? maskedIdentityNumber,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? rejectionReason,
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
    );
  }
}
