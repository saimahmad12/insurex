import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../payments/domain/entities/payout_method.dart';

class SavedPayoutMethodTile extends StatelessWidget {
  const SavedPayoutMethodTile({
    required this.method,
    required this.isBusy,
    required this.onSetDefault,
    required this.onRemove,
    required this.onVerify,
    super.key,
  });

  final PayoutMethod method;
  final bool isBusy;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final Color verificationColor = method.isVerified
        ? const Color(0xFF49E6A4)
        : method.verificationStatus ==
              PayoutMethodVerificationStatus.verificationPending
        ? const Color(0xFFFFB84A)
        : const Color(0xFFFF718A);
    return GlassContainer(
      key: ValueKey<String>('profile_payout_method_${method.id}'),
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.type == PayoutMethodType.bankTransfer
                      ? Icons.account_balance_outlined
                      : Icons.phone_android_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            method.displayName,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (method.isDefault) ...<Widget>[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.violet.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppColors.pink,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.maskedAccount,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _verificationLabel(method.verificationStatus),
                      style: TextStyle(
                        color: verificationColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
                ),
            ],
          ),
          if (!isBusy) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 5,
              children: <Widget>[
                if (!method.isVerified)
                  TextButton(onPressed: onVerify, child: const Text('Verify')),
                if (method.isVerified && !method.isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set Default'),
                  ),
                TextButton(
                  onPressed: onRemove,
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Color(0xFFFFB3BE)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _verificationLabel(PayoutMethodVerificationStatus status) {
    return switch (status) {
      PayoutMethodVerificationStatus.unverified => 'Not verified',
      PayoutMethodVerificationStatus.verificationPending =>
        'Verification pending',
      PayoutMethodVerificationStatus.verified => 'Verified',
      PayoutMethodVerificationStatus.failed => 'Verification failed',
    };
  }
}
