enum ClaimStatus {
  draft,
  imagesPending,
  aiVerificationPending,
  pendingReview,
  approved,
  rejected,
  settled,
}

class ClaimSubmissionResult {
  const ClaimSubmissionResult({
    required this.claimId,
    required this.submittedAt,
    required this.status,
    required this.aiVerificationCompleted,
    required this.blockchainRecordStatus,
  });

  final String claimId;
  final DateTime submittedAt;
  final ClaimStatus status;
  final bool aiVerificationCompleted;
  final String blockchainRecordStatus;
}
