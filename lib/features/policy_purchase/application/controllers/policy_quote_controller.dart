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
  int _requestVersion = 0;

  Future<PolicyQuote?> generate({
    required InsuranceProduct product,
    required PolicyConfiguration configuration,
  }) async {
    if (status == PolicyQuoteStatus.calculating) return null;
    final int requestVersion = ++_requestVersion;
    status = PolicyQuoteStatus.calculating;
    quote = null;
    errorMessage = null;
    _notify();
    try {
      final PolicyQuote generated = await _repository.generateQuote(
        PolicyQuoteRequest(product: product, configuration: configuration),
      );
      if (_disposed || requestVersion != _requestVersion) return null;
      quote = generated;
      status = PolicyQuoteStatus.available;
    } catch (_) {
      if (_disposed || requestVersion != _requestVersion) return null;
      status = PolicyQuoteStatus.unavailable;
      errorMessage = 'The provider could not generate a final quote.';
    }
    _notify();
    return quote;
  }

  bool ensureCurrent({DateTime? now}) {
    if (quote?.isExpiredAt(now ?? DateTime.now()) == true) {
      status = PolicyQuoteStatus.expired;
      _notify();
      return false;
    }
    return quote != null;
  }

  void invalidate() {
    _requestVersion++;
    if (quote == null && status == PolicyQuoteStatus.idle) {
      return;
    }
    quote = null;
    status = PolicyQuoteStatus.idle;
    _notify();
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
