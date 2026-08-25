import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_action_button.dart';

class ClaimNavigationActions extends StatelessWidget {
  const ClaimNavigationActions({
    required this.onBack,
    required this.onContinue,
    required this.continueLabel,
    super.key,
    this.isLoading = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GlassActionButton(
            key: const Key('file_claim_back'),
            label: 'Back',
            onPressed: onBack,
            variant: GlassButtonVariant.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GlassActionButton(
            key: const Key('file_claim_continue'),
            label: continueLabel,
            onPressed: onContinue,
            isLoading: isLoading,
            icon: continueLabel == 'Submit Claim'
                ? Icons.shield_outlined
                : Icons.arrow_forward_rounded,
          ),
        ),
      ],
    );
  }
}
