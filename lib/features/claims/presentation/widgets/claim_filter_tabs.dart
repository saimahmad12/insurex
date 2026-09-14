import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/claim_filter.dart';

class ClaimFilterTabs extends StatelessWidget {
  const ClaimFilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final ClaimFilter selectedFilter;
  final ValueChanged<ClaimFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ClaimFilter.values.map((ClaimFilter filter) {
          final bool selected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              key: ValueKey<String>('claim_filter_${filter.name}'),
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onFilterChanged(filter);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: <Color>[
                            AppColors.blue,
                            AppColors.blue,
                            AppColors.blue,
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
                        : Colors.black.withValues(alpha: 0.65),
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

  static String _label(ClaimFilter filter) {
    return switch (filter) {
      ClaimFilter.all => 'All',
      ClaimFilter.active => 'Active',
      ClaimFilter.approved => 'Approved',
      ClaimFilter.rejected => 'Rejected',
      ClaimFilter.settled => 'Settled',
    };
  }
}
