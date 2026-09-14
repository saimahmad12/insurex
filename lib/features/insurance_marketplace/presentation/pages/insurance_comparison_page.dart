import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/presentation/widgets/profile_page_header.dart';
import '../../domain/entities/insurance_product.dart';
import '../widgets/insurance_product_card.dart';

class InsuranceComparisonPage extends StatelessWidget {
  const InsuranceComparisonPage({
    required this.products,
    required this.onBack,
    required this.onProductPressed,
    super.key,
  });

  final List<InsuranceProduct> products;
  final VoidCallback onBack;
  final ValueChanged<InsuranceProduct> onProductPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            children: <Widget>[
              ProfilePageHeader(title: 'Compare Products', onBack: onBack),
              const SizedBox(height: 22),
              if (products.length < 2)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Text(
                    'Select at least two products from the marketplace to compare.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final InsuranceProduct product in products)
                        SizedBox(
                          width: 270,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(17),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.providerName,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Divider(height: 26),
                                  _ComparisonValue(
                                    label: 'Starting premium',
                                    value: marketplaceMoney(
                                      product.startingPremium,
                                    ),
                                  ),
                                  _ComparisonValue(
                                    label: 'Coverage',
                                    value: marketplaceMoney(
                                      product.maximumCoverage,
                                    ),
                                  ),
                                  _ComparisonValue(
                                    label: 'Deductible',
                                    value: product.availableDeductibles
                                        .map(marketplaceMoney)
                                        .join(', '),
                                  ),
                                  _ComparisonValue(
                                    label: 'Waiting period',
                                    value: product.waitingPeriod,
                                  ),
                                  _ComparisonValue(
                                    label: 'Benefits',
                                    value: product.keyBenefits.join('\n'),
                                  ),
                                  TextButton(
                                    onPressed: () => onProductPressed(product),
                                    child: const Text('View Details'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonValue extends StatelessWidget {
  const _ComparisonValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.black87, height: 1.4),
        ),
      ],
    ),
  );
}
