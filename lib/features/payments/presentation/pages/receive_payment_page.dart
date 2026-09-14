import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import '../../domain/entities/claim_payout.dart';
import '../../domain/entities/payout_method.dart';
import '../widgets/approved_amount_card.dart';
import '../widgets/payout_method_card.dart';
import '../widgets/payout_method_form.dart';
import '../widgets/payout_page_header.dart';

class ReceivePaymentPage extends StatelessWidget {
  const ReceivePaymentPage({
    required this.claim,
    required this.methods,
    required this.selectedMethod,
    required this.selectedMethodType,
    required this.isMethodOperationRunning,
    required this.onBack,
    required this.onSavedMethodSelected,
    required this.onMethodTypeSelected,
    required this.onMethodSubmitted,
    required this.onContinue,
    this.payout,
    this.errorMessage,
    super.key,
  });

  final InsuranceClaim claim;
  final ClaimPayout? payout;
  final List<PayoutMethod> methods;
  final PayoutMethod? selectedMethod;
  final PayoutMethodType? selectedMethodType;
  final bool isMethodOperationRunning;
  final String? errorMessage;
  final VoidCallback onBack;
  final ValueChanged<PayoutMethod> onSavedMethodSelected;
  final ValueChanged<PayoutMethodType> onMethodTypeSelected;
  final ValueChanged<PayoutMethodRequest> onMethodSubmitted;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      PayoutPageHeader(
                        title: 'Receive Payment',
                        onBack: onBack,
                      ),
                      const SizedBox(height: 20),
                      ApprovedAmountCard(claim: claim, payout: payout),
                      const SizedBox(height: 23),
                      const _SectionTitle(title: 'Saved Payout Methods'),
                      const SizedBox(height: 11),
                      if (methods.isEmpty)
                        Container(
                          key: const Key('empty_payout_methods'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Text(
                            'No saved payout methods. Add one below to continue.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        )
                      else
                        ...methods.map((PayoutMethod method) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PayoutMethodCard(
                              method: method,
                              selected: selectedMethod?.id == method.id,
                              onPressed: () {
                                onSavedMethodSelected(method);
                              },
                            ),
                          );
                        }),
                      if (selectedMethod != null &&
                          selectedMethod!.isVerified) ...<Widget>[
                        const SizedBox(height: 5),
                        GlassActionButton(
                          key: const Key('continue_saved_method_button'),
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: onContinue,
                        ),
                      ],
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Add a Payout Method'),
                      const SizedBox(height: 11),
                      Row(
                        children: PayoutMethodType.values.map((
                          PayoutMethodType type,
                        ) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: type == PayoutMethodType.jazzCash
                                    ? 0
                                    : 8,
                              ),
                              child: PayoutMethodTypeCard(
                                type: type,
                                selected: selectedMethodType == type,
                                onPressed: () {
                                  onMethodTypeSelected(type);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (errorMessage != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          key: const Key('payout_method_error'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (selectedMethodType != null) ...<Widget>[
                        const SizedBox(height: 14),
                        PayoutMethodForm(
                          key: ValueKey<PayoutMethodType>(selectedMethodType!),
                          type: selectedMethodType!,
                          isLoading: isMethodOperationRunning,
                          onSubmit: onMethodSubmitted,
                        ),
                      ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
