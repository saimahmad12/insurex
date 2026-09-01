import '../../../insurance_marketplace/domain/entities/insurance_product.dart';

class PolicyConfiguration {
  const PolicyConfiguration({
    required this.productId,
    required this.coverageAmount,
    required this.durationMonths,
    required this.deductible,
    required this.addOns,
    required this.paymentFrequency,
    required this.insuredPeople,
  });

  final String productId;
  final double coverageAmount;
  final int durationMonths;
  final double deductible;
  final List<String> addOns;
  final PremiumFrequency paymentFrequency;
  final int insuredPeople;

  PolicyConfiguration copyWith({
    double? coverageAmount,
    int? durationMonths,
    double? deductible,
    List<String>? addOns,
    PremiumFrequency? paymentFrequency,
    int? insuredPeople,
  }) {
    return PolicyConfiguration(
      productId: productId,
      coverageAmount: coverageAmount ?? this.coverageAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      deductible: deductible ?? this.deductible,
      addOns: List<String>.unmodifiable(addOns ?? this.addOns),
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      insuredPeople: insuredPeople ?? this.insuredPeople,
    );
  }
}
