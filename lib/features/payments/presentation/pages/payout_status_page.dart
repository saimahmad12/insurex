import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../domain/entities/claim_payout.dart';
import '../widgets/payout_page_header.dart';
import '../widgets/payout_status_card.dart';

class PayoutStatusPage extends StatelessWidget {
  const PayoutStatusPage({
    required this.payout,
    required this.isRefreshing,
    required this.onBack,
    required this.onRefresh,
    required this.onRetry,
    required this.onViewReceipt,
    required this.onContactSupport,
    this.refreshErrorMessage,
    super.key,
  });

  final ClaimPayout payout;
  final bool isRefreshing;
  final String? refreshErrorMessage;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onViewReceipt;
  final VoidCallback onContactSupport;

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
                        title: 'Payment Status',
                        onBack: onBack,
                        onRefresh: onRefresh,
                        isRefreshing: isRefreshing,
                      ),
                      const SizedBox(height: 22),
                      PayoutStatusCard(payout: payout),
                      if (refreshErrorMessage != null) ...<Widget>[
                        const SizedBox(height: 13),
                        Text(
                          refreshErrorMessage!,
                          key: const Key('payout_refresh_error'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB3261E),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      _actionButton(),
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

  Widget _actionButton() {
    return switch (payout.status) {
      ClaimPayoutStatus.processing => GlassActionButton(
        key: const Key('check_payout_status_button'),
        label: 'Check Payment Status',
        icon: Icons.refresh_rounded,
        isLoading: isRefreshing,
        onPressed: isRefreshing ? null : onRefresh,
      ),
      ClaimPayoutStatus.paid => GlassActionButton(
        key: const Key('view_payout_receipt_button'),
        label: 'View Receipt',
        icon: Icons.receipt_long_outlined,
        onPressed: onViewReceipt,
      ),
      ClaimPayoutStatus.failed => GlassActionButton(
        key: const Key('retry_payout_button'),
        label: 'Retry Payment',
        icon: Icons.replay_rounded,
        onPressed: onRetry,
      ),
      ClaimPayoutStatus.reversed => GlassActionButton(
        label: 'Contact Support',
        icon: Icons.support_agent_rounded,
        onPressed: onContactSupport,
      ),
      _ => GlassActionButton(
        label: 'Refresh Status',
        icon: Icons.refresh_rounded,
        isLoading: isRefreshing,
        onPressed: isRefreshing ? null : onRefresh,
      ),
    };
  }
}
