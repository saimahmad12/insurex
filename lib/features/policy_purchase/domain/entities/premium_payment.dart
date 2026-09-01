enum PremiumPaymentMethod { bankTransfer, easypaisa, jazzCash }

enum PremiumPaymentStatus { processing, paid, failed, cancelled, refunded }

class PremiumPayment {
  const PremiumPayment({
    required this.id,
    required this.applicationId,
    required this.quoteId,
    required this.amount,
    required this.method,
    required this.status,
    required this.idempotencyKey,
    required this.reference,
    required this.createdAt,
    this.failureMessage,
  });

  final String id;
  final String applicationId;
  final String quoteId;
  final double amount;
  final PremiumPaymentMethod method;
  final PremiumPaymentStatus status;
  final String idempotencyKey;
  final String reference;
  final DateTime createdAt;
  final String? failureMessage;

  PremiumPayment copyWith({
    PremiumPaymentStatus? status,
    String? failureMessage,
  }) {
    return PremiumPayment(
      id: id,
      applicationId: applicationId,
      quoteId: quoteId,
      amount: amount,
      method: method,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey,
      reference: reference,
      createdAt: createdAt,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}
