import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_payment.dart';
import 'claim_formatters.dart';

class ClaimPaymentStatusCard extends StatelessWidget {
  const ClaimPaymentStatusCard({required this.payment, super.key});

  final ClaimPayment payment;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claim_payment_status_card'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.blue,
              ),
              SizedBox(width: 10),
              Text(
                'Payment Status',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _PaymentRow(
            label: 'Approved amount',
            value: ClaimFormatters.amount(payment.amount),
          ),
          _PaymentRow(
            label: 'Payment status',
            value: ClaimFormatters.paymentStatus(payment.status),
          ),
          if (payment.method != null)
            _PaymentRow(label: 'Payment method', value: payment.method!),
          if (payment.transactionReference != null)
            _PaymentRow(
              label: 'Transaction reference',
              value: payment.transactionReference!,
            ),
          if (payment.paidAt != null)
            _PaymentRow(
              label: 'Payment date',
              value: ClaimFormatters.dateTime(payment.paidAt!),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
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
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.52),
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
