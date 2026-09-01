import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../policies/domain/entities/insurance_policy.dart';
import '../../domain/entities/insurance_product.dart';

class InsuranceProductCard extends StatelessWidget {
  const InsuranceProductCard({
    required this.product,
    required this.isFavourite,
    required this.isCompared,
    required this.onPressed,
    required this.onFavourite,
    required this.onCompare,
    super.key,
  });

  final InsuranceProduct product;
  final bool isFavourite;
  final bool isCompared;
  final VoidCallback onPressed;
  final VoidCallback onFavourite;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _categoryIcon(product.category),
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF49E6A4),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              product.providerName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFavourite
                      ? 'Remove saved product'
                      : 'Save product',
                  onPressed: onFavourite,
                  icon: Icon(
                    isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavourite
                        ? AppColors.pink
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _Pill(label: _categoryLabel(product.category)),
                _Pill(
                  label: '${product.availableDurationsMonths.first} months+',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              product.keyBenefits.take(2).join(' • '),
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Value(
                    label: 'Starting premium',
                    value: _money(product.startingPremium),
                  ),
                ),
                Expanded(
                  child: _Value(
                    label: 'Coverage up to',
                    value: _money(product.maximumCoverage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              product.eligibilitySummary,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.64),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onCompare,
              icon: Icon(
                isCompared
                    ? Icons.check_circle_rounded
                    : Icons.compare_arrows_rounded,
                size: 18,
              ),
              label: Text(isCompared ? 'Added to Compare' : 'Add to Compare'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

String marketplaceMoney(double value) => _money(value);

String _money(double value) => 'PKR ${value.toStringAsFixed(0)}';

String _categoryLabel(PolicyType type) => switch (type) {
  PolicyType.vehicle => 'Vehicle',
  PolicyType.health => 'Health',
  PolicyType.travel => 'Travel',
  PolicyType.life => 'Life',
  PolicyType.property => 'Property',
};

IconData _categoryIcon(PolicyType type) => switch (type) {
  PolicyType.vehicle => Icons.directions_car_outlined,
  PolicyType.health => Icons.health_and_safety_outlined,
  PolicyType.travel => Icons.flight_takeoff_rounded,
  PolicyType.life => Icons.favorite_outline_rounded,
  PolicyType.property => Icons.home_work_outlined,
};
