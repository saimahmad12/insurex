import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../domain/entities/claim_payout.dart';
import '../widgets/payout_page_header.dart';
import '../widgets/payout_receipt_card.dart';

class PayoutReceiptPage extends StatelessWidget {
  const PayoutReceiptPage({
    required this.payout,
    required this.onBack,
    required this.onReturnToClaimStatus,
    required this.onReturnToMyClaims,
    required this.onDownloadPlaceholder,
    super.key,
  });

  final ClaimPayout payout;
  final VoidCallback onBack;
  final VoidCallback onReturnToClaimStatus;
  final VoidCallback onReturnToMyClaims;
  final VoidCallback onDownloadPlaceholder;

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
                        title: 'Payment Receipt',
                        onBack: onBack,
                      ),
                      const SizedBox(height: 22),
                      PayoutReceiptCard(payout: payout),
                      const SizedBox(height: 20),
                      GlassActionButton(
                        key: const Key('copy_payment_reference_button'),
                        label: 'Copy Payment Reference',
                        icon: Icons.copy_rounded,
                        onPressed: () {
                          _copyReference(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      GlassActionButton(
                        label: 'Download / Share Receipt',
                        icon: Icons.ios_share_rounded,
                        variant: GlassButtonVariant.secondary,
                        onPressed: onDownloadPlaceholder,
                      ),
                      const SizedBox(height: 10),
                      GlassActionButton(
                        label: 'Return to Claim Status',
                        variant: GlassButtonVariant.secondary,
                        onPressed: onReturnToClaimStatus,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: onReturnToMyClaims,
                        child: const Text('Return to My Claims'),
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

  Future<void> _copyReference(BuildContext context) async {
    final String? reference = payout.reference;
    if (reference == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: reference));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Payment reference copied.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
