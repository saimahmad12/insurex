enum ClaimPaymentStatus { notStarted, processing, paid, failed }

class ClaimPayment {
  const ClaimPayment({
    required this.status,
    required this.amount,
    this.method,
    this.transactionReference,
    this.paidAt,
  });

  final ClaimPaymentStatus status;
  final double amount;
  final String? method;
  final String? transactionReference;
  final DateTime? paidAt;
}
