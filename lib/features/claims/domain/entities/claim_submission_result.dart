enum ClaimStatus {
  submitted,
  aiAnalysisPending,
  aiAnalysisCompleted,
  underReview,
  additionalEvidenceRequired,
  approved,
  rejected,
  paymentProcessing,
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
