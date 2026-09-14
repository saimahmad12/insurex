import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_payment.dart';
import 'claim_formatters.dart';

class ClaimPaymentStatusCard extends StatelessWidget {
  const ClaimPaymentStatusCard({required this.payment, this.action, super.key});

  final ClaimPayment payment;
  final Widget? action;

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
                  color: Colors.black87,
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
          if (payment.maskedDestination != null)
            _PaymentRow(
              label: 'Destination',
              value: payment.maskedDestination!,
            ),
          if (payment.transactionReference != null)
            _PaymentRow(
              label: 'Transaction reference',
              value: payment.transactionReference!,
            ),
          if (payment.requestedAt != null)
            _PaymentRow(
              label: 'Requested',
              value: ClaimFormatters.dateTime(payment.requestedAt!),
            ),
          if (payment.processingAt != null)
            _PaymentRow(
              label: 'Processing since',
              value: ClaimFormatters.dateTime(payment.processingAt!),
            ),
          if (payment.paidAt != null)
            _PaymentRow(
              label: 'Payment date',
              value: ClaimFormatters.dateTime(payment.paidAt!),
            ),
          if (payment.failureMessage != null)
            _PaymentRow(label: 'Status detail', value: payment.failureMessage!),
          if (action != null) ...<Widget>[const SizedBox(height: 8), action!],
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
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
                color: Colors.black87,
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
