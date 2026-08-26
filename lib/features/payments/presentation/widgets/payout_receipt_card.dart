import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../claims/presentation/widgets/claim_formatters.dart';
import '../../domain/entities/claim_payout.dart';

class PayoutReceiptCard extends StatelessWidget {
  const PayoutReceiptCard({required this.payout, super.key});

  final ClaimPayout payout;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('payout_receipt_card'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF49E6A4),
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'Payment Receipt',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _ReceiptRow(label: 'Claim ID', value: payout.claimId),
          _ReceiptRow(
            label: 'Payment reference',
            value: payout.reference ?? 'Pending',
          ),
          _ReceiptRow(
            label: 'Paid amount',
            value: ClaimFormatters.amount(payout.amount),
          ),
          _ReceiptRow(label: 'Method', value: payout.method.displayName),
          _ReceiptRow(label: 'Destination', value: payout.method.maskedAccount),
          _ReceiptRow(
            label: 'Requested',
            value: ClaimFormatters.dateTime(payout.requestedAt),
          ),
          if (payout.paidAt != null)
            _ReceiptRow(
              label: 'Paid',
              value: ClaimFormatters.dateTime(payout.paidAt!),
            ),
          const _ReceiptRow(label: 'Status', value: 'Paid'),
          _ReceiptRow(
            label: 'Blockchain reference',
            value:
                payout.blockchainRecord?.transactionHash ??
                'Pending Integration',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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
