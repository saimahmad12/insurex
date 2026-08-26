import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_action_button.dart';
import '../../application/controllers/claim_status_controller.dart';

class ClaimStatusActionButton extends StatelessWidget {
  const ClaimStatusActionButton({
    required this.action,
    required this.onPressed,
    super.key,
  });

  final ClaimStatusAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassActionButton(
      key: const Key('claim_status_contextual_action'),
      label: _label(action),
      icon: _icon(action),
      onPressed: onPressed,
    );
  }

  static String _label(ClaimStatusAction action) {
    return switch (action) {
      ClaimStatusAction.viewSubmittedInformation =>
        'View Submitted Information',
      ClaimStatusAction.viewAnalysisProgress => 'View Analysis Progress',
      ClaimStatusAction.contactSupport => 'Contact Support',
      ClaimStatusAction.uploadEvidence => 'Upload Evidence',
      ClaimStatusAction.viewDecision => 'View Decision',
      ClaimStatusAction.receivePayment => 'Receive Payment',
      ClaimStatusAction.viewVerificationStatus => 'View Verification Status',
      ClaimStatusAction.trackPayment => 'Track Payment',
      ClaimStatusAction.retryPayment => 'Retry Payment',
      ClaimStatusAction.viewReason => 'View Reason',
      ClaimStatusAction.viewReceipt => 'View Receipt',
    };
  }

  static IconData _icon(ClaimStatusAction action) {
    return switch (action) {
      ClaimStatusAction.viewSubmittedInformation => Icons.description_outlined,
      ClaimStatusAction.viewAnalysisProgress => Icons.auto_awesome_outlined,
      ClaimStatusAction.contactSupport => Icons.support_agent_rounded,
      ClaimStatusAction.uploadEvidence => Icons.upload_rounded,
      ClaimStatusAction.viewDecision => Icons.verified_outlined,
      ClaimStatusAction.receivePayment => Icons.account_balance_wallet_outlined,
      ClaimStatusAction.viewVerificationStatus => Icons.verified_user_outlined,
      ClaimStatusAction.trackPayment => Icons.account_balance_wallet_outlined,
      ClaimStatusAction.retryPayment => Icons.replay_rounded,
      ClaimStatusAction.viewReason => Icons.info_outline_rounded,
      ClaimStatusAction.viewReceipt => Icons.receipt_long_outlined,
    };
  }
}
