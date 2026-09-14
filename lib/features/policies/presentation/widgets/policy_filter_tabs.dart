import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/controllers/policies_controller.dart';

class PolicyFilterTabs extends StatelessWidget {
  const PolicyFilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final PolicyFilter selectedFilter;

  final ValueChanged<PolicyFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _FilterItem(
              title: 'Active',
              selected:
              selectedFilter == PolicyFilter.active,
              onTap: () {
                onFilterChanged(
                  PolicyFilter.active,
                );
              },
            ),
          ),
          Expanded(
            child: _FilterItem(
              title: 'Expired',
              selected:
              selectedFilter == PolicyFilter.expired,
              onTap: () {
                onFilterChanged(
                  PolicyFilter.expired,
                );
              },
            ),
          ),
          Expanded(
            child: _FilterItem(
              title: 'All',
              selected:
              selectedFilter == PolicyFilter.all,
              onTap: () {
                onFilterChanged(
                  PolicyFilter.all,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  const _FilterItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        height: 44,
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black.withValues(alpha: 0.65),
            fontSize: 14,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
