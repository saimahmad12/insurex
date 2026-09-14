import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../claims/presentation/widgets/claim_formatters.dart';
import '../../domain/entities/claim_payout.dart';

class PayoutStatusCard extends StatelessWidget {
  const PayoutStatusCard({required this.payout, super.key});

  final ClaimPayout payout;

  @override
  Widget build(BuildContext context) {
    final Color accent = payoutStatusColor(payout.status);
    return GlassContainer(
      key: const Key('payout_status_card'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(payoutStatusIcon(payout.status), color: accent, size: 28),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  payoutStatusTitle(payout.status),
                  style: TextStyle(
                    color: accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            payoutStatusMessage(payout),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _StatusRow(
            label: 'Approved amount',
            value: ClaimFormatters.amount(payout.amount),
          ),
          _StatusRow(label: 'Payment method', value: payout.method.displayName),
          _StatusRow(label: 'Destination', value: payout.method.maskedAccount),
          if (payout.reference != null)
            _StatusRow(label: 'Payment reference', value: payout.reference!),
          _StatusRow(
            label: 'Requested',
            value: ClaimFormatters.dateTime(payout.requestedAt),
          ),
          if (payout.processingAt != null)
            _StatusRow(
              label: 'Processing',
              value: ClaimFormatters.dateTime(payout.processingAt!),
            ),
          if (payout.paidAt != null)
            _StatusRow(
              label: 'Paid',
              value: ClaimFormatters.dateTime(payout.paidAt!),
            ),
          _StatusRow(
            label: 'Blockchain status',
            value:
                payout.blockchainRecord?.verificationStatus ??
                'Pending Integration',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

String payoutStatusTitle(ClaimPayoutStatus status) {
  return switch (status) {
    ClaimPayoutStatus.processing => 'Payment Processing',
    ClaimPayoutStatus.paid => 'Payment Successful',
    ClaimPayoutStatus.failed => 'Payment Failed',
    ClaimPayoutStatus.reversed => 'Payment Reversed',
    ClaimPayoutStatus.verificationPending => 'Verification Pending',
    ClaimPayoutStatus.ready => 'Payment Ready',
    ClaimPayoutStatus.actionRequired => 'Action Required',
    ClaimPayoutStatus.notAvailable => 'Payment Unavailable',
  };
}

String payoutStatusMessage(ClaimPayout payout) {
  return switch (payout.status) {
    ClaimPayoutStatus.processing =>
      'Your approved claim payment is being processed.',
    ClaimPayoutStatus.paid =>
      '${ClaimFormatters.amount(payout.amount)} has been sent to your selected payout method.',
    ClaimPayoutStatus.failed =>
      payout.failureMessage ??
          'We could not process your payment. Your approved claim remains safe.',
    ClaimPayoutStatus.reversed =>
      payout.failureMessage ?? 'This payment was reversed. Contact support.',
    ClaimPayoutStatus.verificationPending =>
      'Your payout method is being verified.',
    ClaimPayoutStatus.ready => 'Your approved payment is ready to receive.',
    ClaimPayoutStatus.actionRequired =>
      'Select and verify a payout method to continue.',
    ClaimPayoutStatus.notAvailable =>
      'This claim is not currently eligible for payment.',
  };
}

Color payoutStatusColor(ClaimPayoutStatus status) {
  return switch (status) {
    ClaimPayoutStatus.paid => const Color(0xFF49E6A4),
    ClaimPayoutStatus.failed ||
    ClaimPayoutStatus.reversed => const Color(0xFFFF718A),
    ClaimPayoutStatus.verificationPending ||
    ClaimPayoutStatus.actionRequired => const Color(0xFFFFB84A),
    _ => AppColors.blue,
  };
}

IconData payoutStatusIcon(ClaimPayoutStatus status) {
  return switch (status) {
    ClaimPayoutStatus.paid => Icons.check_circle_outline_rounded,
    ClaimPayoutStatus.failed => Icons.error_outline_rounded,
    ClaimPayoutStatus.reversed => Icons.replay_circle_filled_outlined,
    ClaimPayoutStatus.processing => Icons.sync_rounded,
    ClaimPayoutStatus.verificationPending => Icons.verified_user_outlined,
    _ => Icons.account_balance_wallet_outlined,
  };
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
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
