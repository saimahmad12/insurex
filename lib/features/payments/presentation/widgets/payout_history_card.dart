import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../claims/presentation/widgets/claim_formatters.dart';
import '../../domain/entities/claim_payout.dart';
import 'payout_status_card.dart';

class PayoutHistoryCard extends StatelessWidget {
  const PayoutHistoryCard({
    required this.payout,
    required this.onPressed,
    super.key,
  });

  final ClaimPayout payout;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color accent = payoutStatusColor(payout.status);
    return GlassContainer(
      key: ValueKey<String>('payout_history_${payout.id}'),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        payout.claimId,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        payoutStatusTitle(payout.status),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  payout.policyName,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 14),
                _HistoryRow(
                  label: 'Amount',
                  value: ClaimFormatters.amount(payout.amount),
                ),
                _HistoryRow(
                  label: 'Payout method',
                  value: payout.method.displayName,
                ),
                _HistoryRow(
                  label: 'Destination',
                  value: payout.method.maskedAccount,
                ),
                if (payout.reference != null)
                  _HistoryRow(
                    label: 'Payment reference',
                    value: payout.reference!,
                  ),
                _HistoryRow(
                  label: 'Payment date',
                  value: ClaimFormatters.date(
                    payout.paidAt ?? payout.processingAt ?? payout.requestedAt,
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.blue,
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
