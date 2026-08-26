enum ClaimPaymentStatus {
  notStarted,
  verificationPending,
  ready,
  processing,
  paid,
  failed,
  reversed,
}

class ClaimPayment {
  const ClaimPayment({
    required this.status,
    required this.amount,
    this.method,
    this.maskedDestination,
    this.transactionReference,
    this.requestedAt,
    this.processingAt,
    this.paidAt,
    this.failureMessage,
  });

  final ClaimPaymentStatus status;
  final double amount;
  final String? method;
  final String? maskedDestination;
  final String? transactionReference;
  final DateTime? requestedAt;
  final DateTime? processingAt;
  final DateTime? paidAt;
  final String? failureMessage;
}
