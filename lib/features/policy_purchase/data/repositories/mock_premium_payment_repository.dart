import '../../domain/entities/premium_payment.dart';
import '../../domain/repositories/premium_payment_repository.dart';

class MockPremiumPaymentRepository implements PremiumPaymentRepository {
  MockPremiumPaymentRepository({
    this.delay = const Duration(milliseconds: 300),
    this.failPayment = false,
    this.paymentOutcome = PremiumPaymentStatus.paid,
  });

  final Duration delay;
  final bool failPayment;
  final PremiumPaymentStatus paymentOutcome;
  final Map<String, PremiumPayment> _paymentsByIdempotency =
      <String, PremiumPayment>{};
  final Map<String, PremiumPayment> _paymentsByApplication =
      <String, PremiumPayment>{};
  int paymentCallCount = 0;
  int _sequence = 1;

  @override
  Future<PremiumPayment> payPremium({
    required String applicationId,
    required String quoteId,
    required double amount,
    required PremiumPaymentMethod method,
    required String idempotencyKey,
  }) async {
    paymentCallCount++;
    await _wait();
    if (failPayment) {
      throw StateError('The payment provider is unavailable.');
    }
    final PremiumPayment? idempotent = _paymentsByIdempotency[idempotencyKey];
    if (idempotent != null) {
      if (idempotent.applicationId != applicationId ||
          idempotent.quoteId != quoteId ||
          idempotent.amount != amount) {
        throw StateError('The idempotency key belongs to another payment.');
      }
      return idempotent;
    }
    final PremiumPayment? existing = _paymentsByApplication[applicationId];
    if (existing != null &&
        (existing.status == PremiumPaymentStatus.processing ||
            existing.status == PremiumPaymentStatus.paid)) {
      return existing;
    }
    final DateTime now = DateTime.now();
    final PremiumPayment payment = PremiumPayment(
      id: 'PREMIUM-${(_sequence++).toString().padLeft(5, '0')}',
      applicationId: applicationId,
      quoteId: quoteId,
      amount: amount,
      method: method,
      status: paymentOutcome,
      idempotencyKey: idempotencyKey,
      reference: 'PMT-${now.year}-${_sequence.toString().padLeft(5, '0')}',
      createdAt: now,
      failureMessage: paymentOutcome == PremiumPaymentStatus.failed
          ? 'The payment provider could not complete the transaction.'
          : null,
    );
    _paymentsByIdempotency[idempotencyKey] = payment;
    _paymentsByApplication[applicationId] = payment;
    return payment;
  }

  @override
  Future<PremiumPayment?> getPaymentByApplication(String applicationId) async {
    await _wait();
    return _paymentsByApplication[applicationId];
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
