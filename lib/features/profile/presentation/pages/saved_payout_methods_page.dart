import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../payments/domain/entities/payout_method.dart';
import '../../../payments/presentation/widgets/payout_method_card.dart';
import '../../../payments/presentation/widgets/payout_method_form.dart';
import '../../application/controllers/saved_payout_methods_controller.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';
import '../widgets/saved_payout_method_tile.dart';

class SavedPayoutMethodsPage extends StatefulWidget {
  const SavedPayoutMethodsPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final SavedPayoutMethodsController controller;
  final VoidCallback onBack;

  @override
  State<SavedPayoutMethodsPage> createState() => _SavedPayoutMethodsPageState();
}

class _SavedPayoutMethodsPageState extends State<SavedPayoutMethodsPage> {
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
                        child: ProfilePageHeader(
                          title: 'Payout Methods',
                          onBack: widget.onBack,
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
    if (widget.controller.isLoading) {
      return const Center(
        key: Key('saved_payout_methods_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    if (widget.controller.loadStatus == SavedPayoutMethodsLoadStatus.failure &&
        widget.controller.methods.isEmpty) {
      return ProfileStateMessage(
        key: const Key('saved_payout_methods_error'),
        icon: Icons.error_outline_rounded,
        title: 'Payout methods unavailable',
        message: widget.controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Saved Methods',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.controller.methods.isEmpty)
                  const GlassContainer(
                    key: Key('saved_payout_methods_empty'),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.blue,
                          size: 34,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No saved payout methods',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Add a bank account or mobile wallet below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final PayoutMethod method
                      in widget.controller.methods) ...<Widget>[
                    SavedPayoutMethodTile(
                      method: method,
                      isBusy: widget.controller.activeMethodId == method.id,
                      onSetDefault: () {
                        widget.controller.setDefault(method);
                      },
                      onVerify: () {
                        widget.controller.verifyMethod(method);
                      },
                      onRemove: () {
                        _confirmRemove(method);
                      },
                    ),
                    const SizedBox(height: 11),
                  ],
                if (widget.controller.operationErrorMessage !=
                    null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.operationErrorMessage!,
                    key: const Key('saved_payout_method_operation_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFB3BE),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Add a Payout Method',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: PayoutMethodType.values.map((
                    PayoutMethodType type,
                  ) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: type == PayoutMethodType.jazzCash ? 0 : 8,
                        ),
                        child: PayoutMethodTypeCard(
                          type: type,
                          selected: widget.controller.selectedType == type,
                          onPressed: () {
                            widget.controller.selectType(type);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (widget.controller.selectedType != null) ...<Widget>[
                  const SizedBox(height: 14),
                  PayoutMethodForm(
                    key: ValueKey<PayoutMethodType>(
                      widget.controller.selectedType!,
                    ),
                    type: widget.controller.selectedType!,
                    isLoading: widget.controller.isAddingOrVerifying,
                    onSubmit: widget.controller.addAndVerifyMethod,
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Only masked destinations are stored or displayed. InsureX never asks for wallet PINs, OTPs, CVV values, or provider credentials here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmRemove(PayoutMethod method) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151E42),
          title: const Text(
            'Remove payout method?',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Remove ${method.displayName} ending ${method.maskedAccount.substring(method.maskedAccount.length - 4)}?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Color(0xFFFFB3BE)),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await widget.controller.remove(method);
    }
  }
}
