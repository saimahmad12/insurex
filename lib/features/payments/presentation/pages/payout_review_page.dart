import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import '../../../claims/presentation/widgets/claim_formatters.dart';
import '../../domain/entities/payout_method.dart';
import '../widgets/payout_page_header.dart';

class PayoutReviewPage extends StatelessWidget {
  const PayoutReviewPage({
    required this.claim,
    required this.method,
    required this.consentConfirmed,
    required this.isSubmitting,
    required this.onBack,
    required this.onConsentChanged,
    required this.onConfirm,
    this.errorMessage,
    super.key,
  });

  final InsuranceClaim claim;
  final PayoutMethod method;
  final bool consentConfirmed;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onBack;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      PayoutPageHeader(
                        title: 'Review and Confirm',
                        onBack: onBack,
                      ),
                      const SizedBox(height: 22),
                      GlassContainer(
                        key: const Key('payout_confirmation_card'),
                        padding: const EdgeInsets.all(19),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Payout Details',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ReviewRow(label: 'Claim ID', value: claim.id),
                            _ReviewRow(
                              label: 'Approved amount',
                              value: ClaimFormatters.amount(
                                claim.approvedAmount ?? 0,
                              ),
                            ),
                            _ReviewRow(
                              label: 'Payout method',
                              value: method.displayName,
                            ),
                            _ReviewRow(
                              label: 'Destination',
                              value: method.maskedAccount,
                            ),
                            _ReviewRow(
                              label: 'Account holder',
                              value: method.accountHolderName,
                            ),
                            const _ReviewRow(
                              label: 'Processing',
                              value: 'Mock provider • usually a few moments',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      CheckboxListTile(
                        key: const Key('payout_consent_checkbox'),
                        value: consentConfirmed,
                        onChanged: isSubmitting
                            ? null
                            : (bool? value) {
                                onConsentChanged(value ?? false);
                              },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.blue,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'I confirm that the payout details are correct and belong to me.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          errorMessage!,
                          key: const Key('payout_submission_error'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 15),
                      GlassActionButton(
                        key: const Key('confirm_payout_button'),
                        label: 'Confirm Payout',
                        icon: Icons.account_balance_wallet_outlined,
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : onConfirm,
                      ),
                      const SizedBox(height: 11),
                      GlassActionButton(
                        label: 'Back to Edit',
                        variant: GlassButtonVariant.secondary,
                        onPressed: isSubmitting ? null : onBack,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
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
