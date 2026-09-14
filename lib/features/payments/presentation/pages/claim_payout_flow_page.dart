import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/claim_payout_controller.dart';
import 'payout_receipt_page.dart';
import 'payout_review_page.dart';
import 'payout_status_page.dart';
import 'receive_payment_page.dart';

class ClaimPayoutFlowPage extends StatefulWidget {
  const ClaimPayoutFlowPage({
    required this.controller,
    required this.onClose,
    required this.onReturnToClaimStatus,
    required this.onReturnToMyClaims,
    required this.onPlaceholderAction,
    super.key,
  });

  final ClaimPayoutController controller;
  final VoidCallback onClose;
  final VoidCallback onReturnToClaimStatus;
  final VoidCallback onReturnToMyClaims;
  final ValueChanged<String> onPlaceholderAction;

  @override
  State<ClaimPayoutFlowPage> createState() => _ClaimPayoutFlowPageState();
}

class _ClaimPayoutFlowPageState extends State<ClaimPayoutFlowPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        if (widget.controller.isInitialLoading) {
          return const Scaffold(
            body: GlassBackground(
              child: Center(
                key: Key('claim_payout_initial_loading'),
                child: CircularProgressIndicator(color: AppColors.blue),
              ),
            ),
          );
        }
        if (widget.controller.initialStatus ==
                ClaimPayoutInitialStatus.failure ||
            widget.controller.initialStatus ==
                ClaimPayoutInitialStatus.ineligible) {
          return _FlowMessage(
            title:
                widget.controller.initialStatus ==
                    ClaimPayoutInitialStatus.ineligible
                ? 'Payment Unavailable'
                : 'Unable to Load Payment',
            message:
                widget.controller.initialErrorMessage ??
                'Payout information is unavailable.',
            actionLabel:
                widget.controller.initialStatus ==
                    ClaimPayoutInitialStatus.failure
                ? 'Try Again'
                : 'Go Back',
            onAction:
                widget.controller.initialStatus ==
                    ClaimPayoutInitialStatus.failure
                ? widget.controller.retryInitialLoad
                : widget.onClose,
          );
        }

        final claim = widget.controller.claim;
        if (claim == null) {
          return _FlowMessage(
            title: 'Payment Unavailable',
            message: 'The approved claim could not be found.',
            actionLabel: 'Go Back',
            onAction: widget.onClose,
          );
        }

        return switch (widget.controller.flowStep) {
          ClaimPayoutFlowStep.method => ReceivePaymentPage(
            claim: claim,
            payout: widget.controller.payout,
            methods: widget.controller.methods,
            selectedMethod: widget.controller.selectedMethod,
            selectedMethodType: widget.controller.selectedMethodType,
            isMethodOperationRunning:
                widget.controller.isMethodOperationRunning,
            errorMessage: widget.controller.methodErrorMessage,
            onBack: widget.onClose,
            onSavedMethodSelected: widget.controller.selectSavedMethod,
            onMethodTypeSelected: widget.controller.selectMethodType,
            onMethodSubmitted: widget.controller.addAndVerifyMethod,
            onContinue: widget.controller.continueWithSelectedMethod,
          ),
          ClaimPayoutFlowStep.review => PayoutReviewPage(
            claim: claim,
            method: widget.controller.selectedMethod!,
            consentConfirmed: widget.controller.consentConfirmed,
            isSubmitting: widget.controller.isSubmitting,
            errorMessage: widget.controller.submissionErrorMessage,
            onBack: widget.controller.editPayoutMethod,
            onConsentChanged: widget.controller.updateConsent,
            onConfirm: widget.controller.confirmPayout,
          ),
          ClaimPayoutFlowStep.status => PayoutStatusPage(
            payout: widget.controller.payout!,
            isRefreshing: widget.controller.isRefreshingStatus,
            refreshErrorMessage: widget.controller.refreshErrorMessage,
            onBack: widget.onClose,
            onRefresh: widget.controller.refreshPayoutStatus,
            onRetry: widget.controller.retryFailedPayout,
            onViewReceipt: widget.controller.showReceipt,
            onContactSupport: () {
              widget.onPlaceholderAction('Claim payout support');
            },
          ),
          ClaimPayoutFlowStep.receipt => PayoutReceiptPage(
            payout: widget.controller.payout!,
            onBack: widget.controller.showStatus,
            onReturnToClaimStatus: widget.onReturnToClaimStatus,
            onReturnToMyClaims: widget.onReturnToMyClaims,
            onDownloadPlaceholder: () {
              widget.onPlaceholderAction('Receipt download and sharing');
            },
          ),
        };
      },
    );
  }
}

class _FlowMessage extends StatelessWidget {
  const _FlowMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.blue,
                        size: 43,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 19),
                      GlassActionButton(
                        label: actionLabel,
                        onPressed: onAction,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
