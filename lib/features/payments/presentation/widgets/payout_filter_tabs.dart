import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payout_filter.dart';

class PayoutFilterTabs extends StatelessWidget {
  const PayoutFilterTabs({
    required this.selectedFilter,
    required this.onChanged,
    super.key,
  });

  final PayoutFilter selectedFilter;
  final ValueChanged<PayoutFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PayoutFilter.values.map((PayoutFilter filter) {
          final bool selected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              key: ValueKey<String>('payout_filter_${filter.name}'),
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onChanged(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: <Color>[
                            AppColors.electricBlue,
                            AppColors.violet,
                            AppColors.pink,
                          ],
                        )
                      : null,
                  color: selected
                      ? null
                      : AppColors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  _label(filter),
                  style: TextStyle(
                    color: selected
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _label(PayoutFilter filter) {
    return switch (filter) {
      PayoutFilter.all => 'All',
      PayoutFilter.processing => 'Processing',
      PayoutFilter.paid => 'Paid',
      PayoutFilter.failed => 'Failed',
    };
  }
}
