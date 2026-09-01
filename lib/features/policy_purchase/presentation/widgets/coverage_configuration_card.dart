import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import '../../../insurance_marketplace/presentation/widgets/insurance_product_card.dart';
import '../../domain/entities/policy_configuration.dart';

class CoverageConfigurationCard extends StatelessWidget {
  const CoverageConfigurationCard({
    required this.product,
    required this.configuration,
    required this.onChanged,
    super.key,
  });

  final InsuranceProduct product;
  final PolicyConfiguration configuration;
  final ValueChanged<PolicyConfiguration> onChanged;

  @override
  Widget build(BuildContext context) {
    final int divisions =
        ((product.maximumCoverage - product.minimumCoverage) /
                product.minimumCoverage)
            .round()
            .clamp(1, 20);
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            marketplaceMoney(configuration.coverageAmount),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'Selected coverage',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Slider(
            key: const Key('coverage_amount_slider'),
            min: product.minimumCoverage,
            max: product.maximumCoverage,
            divisions: divisions,
            value: configuration.coverageAmount.clamp(
              product.minimumCoverage,
              product.maximumCoverage,
            ),
            onChanged: (double value) =>
                onChanged(configuration.copyWith(coverageAmount: value)),
          ),
          DropdownButtonFormField<int>(
            key: const Key('coverage_duration_dropdown'),
            initialValue: configuration.durationMonths,
            decoration: const InputDecoration(labelText: 'Duration'),
            items: product.availableDurationsMonths
                .map(
                  (int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value months'),
                  ),
                )
                .toList(),
            onChanged: (int? value) {
              if (value != null) {
                onChanged(configuration.copyWith(durationMonths: value));
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            key: const Key('coverage_deductible_dropdown'),
            initialValue: configuration.deductible,
            decoration: const InputDecoration(labelText: 'Deductible'),
            items: product.availableDeductibles
                .map(
                  (double value) => DropdownMenuItem<double>(
                    value: value,
                    child: Text(marketplaceMoney(value)),
                  ),
                )
                .toList(),
            onChanged: (double? value) {
              if (value != null) {
                onChanged(configuration.copyWith(deductible: value));
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PremiumFrequency>(
            key: const Key('coverage_frequency_dropdown'),
            initialValue: configuration.paymentFrequency,
            decoration: const InputDecoration(labelText: 'Payment frequency'),
            items: product.paymentFrequencies
                .map(
                  (PremiumFrequency value) =>
                      DropdownMenuItem<PremiumFrequency>(
                        value: value,
                        child: Text(_frequency(value)),
                      ),
                )
                .toList(),
            onChanged: (PremiumFrequency? value) {
              if (value != null) {
                onChanged(configuration.copyWith(paymentFrequency: value));
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: const Key('coverage_people_dropdown'),
            initialValue: configuration.insuredPeople,
            decoration: const InputDecoration(labelText: 'Insured people'),
            items: List<DropdownMenuItem<int>>.generate(
              6,
              (int index) => DropdownMenuItem<int>(
                value: index + 1,
                child: Text('${index + 1}'),
              ),
            ),
            onChanged: (int? value) {
              if (value != null) {
                onChanged(configuration.copyWith(insuredPeople: value));
              }
            },
          ),
          if (product.availableAddOns.isNotEmpty) ...<Widget>[
            const SizedBox(height: 15),
            const Text(
              'Add-ons',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            for (final String addOn in product.availableAddOns)
              CheckboxListTile(
                key: ValueKey<String>('coverage_add_on_$addOn'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  addOn,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                value: configuration.addOns.contains(addOn),
                onChanged: (bool? selected) {
                  final List<String> values = <String>[...configuration.addOns];
                  if (selected == true) {
                    values.add(addOn);
                  } else {
                    values.remove(addOn);
                  }
                  onChanged(configuration.copyWith(addOns: values));
                },
              ),
          ],
          const SizedBox(height: 10),
          Text(
            key: const Key('coverage_estimated_premium'),
            'Estimated premium: ${marketplaceMoney(_estimate(product, configuration))}. The provider/backend will generate the authoritative final quote.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

double _estimate(InsuranceProduct product, PolicyConfiguration value) =>
    product.startingPremium *
    (value.coverageAmount / product.minimumCoverage).clamp(1.0, 8.0) *
    value.durationMonths /
    12;

String _frequency(PremiumFrequency value) => switch (value) {
  PremiumFrequency.monthly => 'Monthly',
  PremiumFrequency.quarterly => 'Quarterly',
  PremiumFrequency.annually => 'Annually',
  PremiumFrequency.single => 'Single payment',
};
