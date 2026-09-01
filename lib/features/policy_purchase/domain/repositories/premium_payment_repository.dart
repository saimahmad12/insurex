import '../entities/premium_payment.dart';

abstract interface class PremiumPaymentRepository {
  Future<PremiumPayment> payPremium({
    required String applicationId,
    required String quoteId,
    required double amount,
    required PremiumPaymentMethod method,
    required String idempotencyKey,
  });

  Future<PremiumPayment?> getPaymentByApplication(String applicationId);
}
