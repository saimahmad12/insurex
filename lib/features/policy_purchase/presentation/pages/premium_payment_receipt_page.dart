import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../insurance_marketplace/presentation/widgets/insurance_product_card.dart';
import '../../../profile/presentation/widgets/profile_page_header.dart';
import '../../domain/entities/premium_payment.dart';

class PremiumPaymentReceiptPage extends StatelessWidget {
  const PremiumPaymentReceiptPage({
    required this.payment,
    required this.onBack,
    super.key,
  });

  final PremiumPayment payment;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            children: <Widget>[
              ProfilePageHeader(title: 'Payment Receipt', onBack: onBack),
              const SizedBox(height: 22),
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.blue,
                      size: 46,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      marketplaceMoney(payment.amount),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _row('Reference', payment.reference),
                    _row('Application', payment.applicationId),
                    _row('Quote', payment.quoteId),
                    _row('Method', _method(payment.method)),
                    _row('Status', _status(payment.status)),
                    _row('Date', _date(payment.createdAt)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 11),
  child: Row(
    children: <Widget>[
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ),
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

String _method(PremiumPaymentMethod value) => switch (value) {
  PremiumPaymentMethod.bankTransfer => 'Bank Transfer',
  PremiumPaymentMethod.easypaisa => 'Easypaisa',
  PremiumPaymentMethod.jazzCash => 'JazzCash',
};

String _status(PremiumPaymentStatus value) => switch (value) {
  PremiumPaymentStatus.processing => 'Processing',
  PremiumPaymentStatus.paid => 'Paid',
  PremiumPaymentStatus.failed => 'Failed',
  PremiumPaymentStatus.cancelled => 'Cancelled',
  PremiumPaymentStatus.refunded => 'Refunded',
};

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
