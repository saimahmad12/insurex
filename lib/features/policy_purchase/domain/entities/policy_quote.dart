import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import 'policy_configuration.dart';

class PolicyQuote {
  const PolicyQuote({
    required this.id,
    required this.providerName,
    required this.productName,
    required this.configuration,
    required this.basePremium,
    required this.taxes,
    required this.fees,
    required this.discounts,
    required this.totalPremium,
    required this.effectiveDate,
    required this.expiresAt,
  });

  final String id;
  final String providerName;
  final String productName;
  final PolicyConfiguration configuration;
  final double basePremium;
  final double taxes;
  final double fees;
  final double discounts;
  final double totalPremium;
  final DateTime effectiveDate;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime time) => !expiresAt.isAfter(time);
}

class PolicyQuoteRequest {
  const PolicyQuoteRequest({
    required this.product,
    required this.configuration,
  });

  final InsuranceProduct product;
  final PolicyConfiguration configuration;
}
