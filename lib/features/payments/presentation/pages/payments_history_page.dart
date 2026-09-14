import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/payments_history_controller.dart';
import '../../domain/entities/claim_payout.dart';
import '../widgets/payout_filter_tabs.dart';
import '../widgets/payout_history_card.dart';
import '../widgets/payout_page_header.dart';

class PaymentsHistoryPage extends StatefulWidget {
  const PaymentsHistoryPage({
    required this.controller,
    required this.onBack,
    required this.onPayoutPressed,
    super.key,
  });

  final PaymentsHistoryController controller;
  final VoidCallback onBack;
  final ValueChanged<ClaimPayout> onPayoutPressed;

  @override
  State<PaymentsHistoryPage> createState() => _PaymentsHistoryPageState();
}

class _PaymentsHistoryPageState extends State<PaymentsHistoryPage> {
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
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: PayoutPageHeader(
                          title: 'Payments',
                          onBack: widget.onBack,
                          onRefresh: widget.controller.refresh,
                          isRefreshing: widget.controller.isRefreshing,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.controller.isInitialLoading) {
      return const Center(
        key: Key('payments_history_initial_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }

    if (widget.controller.loadStatus == PaymentsHistoryLoadStatus.failure &&
        widget.controller.payouts.isEmpty) {
      return _PaymentsMessage(
        key: const Key('payments_history_error'),
        icon: Icons.error_outline_rounded,
        title: 'Unable to load payments',
        message:
            widget.controller.errorMessage ??
            'Payment history is unavailable. Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }

    if (widget.controller.loadStatus == PaymentsHistoryLoadStatus.empty) {
      return const _PaymentsMessage(
        key: Key('payments_history_empty'),
        icon: Icons.account_balance_wallet_outlined,
        title: 'No payments yet',
        message: 'Approved claim payments will appear here.',
      );
    }

    final List<ClaimPayout> visiblePayouts = widget.controller.visiblePayouts;
    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: widget.controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PayoutFilterTabs(
                    selectedFilter: widget.controller.selectedFilter,
                    onChanged: widget.controller.changeFilter,
                  ),
                  if (widget.controller.refreshErrorMessage !=
                      null) ...<Widget>[
                    const SizedBox(height: 13),
                    Text(
                      widget.controller.refreshErrorMessage!,
                      key: const Key('payments_history_refresh_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB3261E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (visiblePayouts.isEmpty)
                    const GlassContainer(
                      key: Key('payments_history_filter_empty'),
                      padding: EdgeInsets.all(22),
                      child: Text(
                        'No payments match this filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    for (final ClaimPayout payout
                        in visiblePayouts) ...<Widget>[
                      PayoutHistoryCard(
                        payout: payout,
                        onPressed: () {
                          widget.onPayoutPressed(payout);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsMessage extends StatelessWidget {
  const _PaymentsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: AppColors.blue, size: 44),
                const SizedBox(height: 15),
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
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 20),
                  GlassActionButton(label: actionLabel!, onPressed: onAction),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
