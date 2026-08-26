enum BlockchainRecordStatus {
  pendingIntegration,
  verificationPending,
  secured,
  failed,
}

class BlockchainClaimRecord {
  const BlockchainClaimRecord({
    required this.status,
    required this.verificationStatus,
    this.transactionHash,
    this.recordedAt,
  });

  final BlockchainRecordStatus status;
  final String verificationStatus;
  final String? transactionHash;
  final DateTime? recordedAt;
}
