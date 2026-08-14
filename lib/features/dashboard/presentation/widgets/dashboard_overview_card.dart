import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class DashboardOverviewCard
    extends StatelessWidget {
  const DashboardOverviewCard({
    required this.activePolicies,
    required this.activeClaims,
    required this.totalClaims,
    super.key,
  });

  final int activePolicies;
  final int activeClaims;
  final int totalClaims;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Column(
        children: <Widget>[
          _OverviewRow(
            label: 'Active Policies',
            value: '$activePolicies',
          ),

          _Divider(),

          _OverviewRow(
            label: 'Active Claims',
            value: '$activeClaims',
          ),

          _Divider(),

          _OverviewRow(
            label: 'Total Claims',
            value: '$totalClaims',
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.88,
                ),
                fontSize: 12.5,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.white.withValues(
        alpha: 0.09,
      ),
    );
  }
}