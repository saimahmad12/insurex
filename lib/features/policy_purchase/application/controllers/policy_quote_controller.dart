import 'package:flutter/foundation.dart';

import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import '../../domain/entities/policy_configuration.dart';
import '../../domain/entities/policy_quote.dart';
import '../../domain/repositories/policy_purchase_repository.dart';

enum PolicyQuoteStatus { idle, calculating, available, expired, unavailable }

class PolicyQuoteController extends ChangeNotifier {
  PolicyQuoteController({required PolicyPurchaseRepository repository})
    : _repository = repository;

  final PolicyPurchaseRepository _repository;
  PolicyQuoteStatus status = PolicyQuoteStatus.idle;
  PolicyQuote? quote;
  String? errorMessage;

  Future<PolicyQuote?> generate({
    required InsuranceProduct product,
    required PolicyConfiguration configuration,
  }) async {
    if (status == PolicyQuoteStatus.calculating) return null;
    status = PolicyQuoteStatus.calculating;
    errorMessage = null;
    notifyListeners();
    try {
      quote = await _repository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      status = PolicyQuoteStatus.available;
    } catch (_) {
      status = PolicyQuoteStatus.unavailable;
      errorMessage = 'The provider could not generate a final quote.';
    }
    notifyListeners();
    return quote;
  }

  bool ensureCurrent({DateTime? now}) {
    if (quote?.isExpiredAt(now ?? DateTime.now()) == true) {
      status = PolicyQuoteStatus.expired;
      notifyListeners();
      return false;
    }
    return quote != null;
  }

  void invalidate() {
    if (quote == null && status == PolicyQuoteStatus.idle) {
      return;
    }
    quote = null;
    status = PolicyQuoteStatus.idle;
    notifyListeners();
  }
}
