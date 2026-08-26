import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import '../../../claims/presentation/widgets/claim_formatters.dart';
import '../../domain/entities/claim_payout.dart';

class ApprovedAmountCard extends StatelessWidget {
  const ApprovedAmountCard({required this.claim, this.payout, super.key});

  final InsuranceClaim claim;
  final ClaimPayout? payout;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('approved_amount_card'),
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Approved Claim Amount',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.62),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            ClaimFormatters.amount(claim.approvedAmount ?? 0),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 17),
          _DetailRow(label: 'Claim ID', value: claim.id),
          _DetailRow(label: 'Policy', value: claim.policyName),
          _DetailRow(
            label: 'Payout status',
            value: payout == null ? 'Ready' : _statusLabel(payout!.status),
            isLast: true,
          ),
        ],
      ),
    );
  }

  static String _statusLabel(ClaimPayoutStatus status) {
    return switch (status) {
      ClaimPayoutStatus.notAvailable => 'Not Available',
      ClaimPayoutStatus.actionRequired => 'Action Required',
      ClaimPayoutStatus.verificationPending => 'Verification Pending',
      ClaimPayoutStatus.ready => 'Ready',
      ClaimPayoutStatus.processing => 'Processing',
      ClaimPayoutStatus.paid => 'Paid',
      ClaimPayoutStatus.failed => 'Failed',
      ClaimPayoutStatus.reversed => 'Reversed',
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.52),
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
