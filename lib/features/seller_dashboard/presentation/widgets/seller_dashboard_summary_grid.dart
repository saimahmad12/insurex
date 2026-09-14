import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/seller_dashboard.dart';
import 'seller_dashboard_sections.dart';

class SellerDashboardSummaryGrid extends StatelessWidget {
  const SellerDashboardSummaryGrid({required this.summary, super.key});

  final SellerDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final List<_SummaryItem> items = <_SummaryItem>[
      _SummaryItem(
        keyName: 'active_products',
        label: 'Active Products',
        value: formatSellerNumber(summary.activeProducts),
        icon: Icons.inventory_2_outlined,
      ),
      _SummaryItem(
        keyName: 'pending_applications',
        label: 'Pending Applications',
        value: formatSellerNumber(summary.pendingApplications),
        icon: Icons.assignment_late_outlined,
      ),
      _SummaryItem(
        keyName: 'active_policies',
        label: 'Active Policies',
        value: formatSellerNumber(summary.activePolicies),
        icon: Icons.verified_user_outlined,
      ),
      _SummaryItem(
        keyName: 'open_claims',
        label: 'Open Claims',
        value: formatSellerNumber(summary.openClaims),
        icon: Icons.fact_check_outlined,
      ),
      _SummaryItem(
        keyName: 'premium_collected',
        label: 'Premium Collected',
        value: formatSellerCurrency(summary.premiumCollected),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _SummaryItem(
        keyName: 'pending_settlements',
        label: 'Pending Settlements',
        value: formatSellerCurrency(summary.pendingSettlements),
        icon: Icons.payments_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 12;
        final int columns = constraints.maxWidth < 280 ? 1 : 2;
        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (_SummaryItem item) => SizedBox(
                  width: itemWidth,
                  child: _SummaryCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 106),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(item.icon, color: AppColors.blue, size: 23),
            const SizedBox(height: 13),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                item.value,
                key: Key('seller_summary_${item.keyName}'),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 2,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.76),
                fontSize: 10.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.keyName,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String keyName;
  final String label;
  final String value;
  final IconData icon;
}
