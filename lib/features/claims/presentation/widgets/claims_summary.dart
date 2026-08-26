import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class ClaimsSummary extends StatelessWidget {
  const ClaimsSummary({
    required this.total,
    required this.active,
    required this.approved,
    required this.settled,
    super.key,
  });

  final int total;
  final int active;
  final int approved;
  final int settled;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claims_summary'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: <Widget>[
          _SummaryValue(label: 'Total', value: total),
          _divider(),
          _SummaryValue(label: 'Active', value: active),
          _divider(),
          _SummaryValue(label: 'Approved', value: approved),
          _divider(),
          _SummaryValue(label: 'Settled', value: settled),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.white.withValues(alpha: 0.08),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
