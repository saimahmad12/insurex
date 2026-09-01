import 'package:flutter/foundation.dart';

import '../../domain/entities/premium_payment.dart';
import '../../domain/repositories/premium_payment_repository.dart';

enum PremiumPaymentOperationStatus { idle, processing, complete, failure }

class PremiumPaymentController extends ChangeNotifier {
  PremiumPaymentController({required PremiumPaymentRepository repository})
    : _repository = repository;

  final PremiumPaymentRepository _repository;
  PremiumPaymentOperationStatus operationStatus =
      PremiumPaymentOperationStatus.idle;
  PremiumPaymentMethod selectedMethod = PremiumPaymentMethod.bankTransfer;
  PremiumPayment? payment;
  String? errorMessage;
  String? _idempotencyKey;

  void selectMethod(PremiumPaymentMethod method) {
    if (operationStatus == PremiumPaymentOperationStatus.processing) return;
    selectedMethod = method;
    notifyListeners();
  }

  Future<PremiumPayment?> pay({
    required String applicationId,
    required String quoteId,
    required double amount,
  }) async {
    if (operationStatus == PremiumPaymentOperationStatus.processing ||
        payment?.status == PremiumPaymentStatus.paid) {
      return payment;
    }
    _idempotencyKey ??=
        'premium-$applicationId-$quoteId-${DateTime.now().microsecondsSinceEpoch}';
    operationStatus = PremiumPaymentOperationStatus.processing;
    errorMessage = null;
    notifyListeners();
    try {
      payment = await _repository.payPremium(
        applicationId: applicationId,
        quoteId: quoteId,
        amount: amount,
        method: selectedMethod,
        idempotencyKey: _idempotencyKey!,
      );
      if (payment?.status == PremiumPaymentStatus.paid ||
          payment?.status == PremiumPaymentStatus.processing) {
        operationStatus = PremiumPaymentOperationStatus.complete;
      } else {
        operationStatus = PremiumPaymentOperationStatus.failure;
        errorMessage =
            payment?.failureMessage ??
            'The payment was not completed. No duplicate charge was created.';
        _idempotencyKey = null;
      }
    } catch (_) {
      operationStatus = PremiumPaymentOperationStatus.failure;
      errorMessage = 'The premium payment could not be completed.';
    }
    notifyListeners();
    return payment;
  }
}
