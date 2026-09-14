import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/payout_method.dart';

class PayoutMethodCard extends StatelessWidget {
  const PayoutMethodCard({
    required this.method,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final PayoutMethod method;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: ValueKey<String>('saved_payout_method_${method.id}'),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                _MethodIcon(type: method.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        method.displayName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.maskedAccount,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.62,
                          ),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.blue : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PayoutMethodTypeCard extends StatelessWidget {
  const PayoutMethodTypeCard({
    required this.type,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final PayoutMethodType type;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>('payout_method_type_${type.name}'),
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: selected ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: <Widget>[
            _MethodIcon(type: type),
            const SizedBox(height: 8),
            Text(
              payoutMethodTypeLabel(type),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.blue : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon({required this.type});

  final PayoutMethodType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        type == PayoutMethodType.bankTransfer
            ? Icons.account_balance_outlined
            : Icons.phone_android_rounded,
        color: AppColors.blue,
        size: 20,
      ),
    );
  }
}

String payoutMethodTypeLabel(PayoutMethodType type) {
  return switch (type) {
    PayoutMethodType.bankTransfer => 'Bank Transfer',
    PayoutMethodType.easypaisa => 'Easypaisa',
    PayoutMethodType.jazzCash => 'JazzCash',
  };
}
