import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/seller_authentication.dart';
import '../../domain/entities/seller_registration.dart';

class SellerAccountStatusPage extends StatelessWidget {
  const SellerAccountStatusPage({
    required this.account,
    required this.onBack,
    required this.onContactSupport,
    required this.onRetryRegistration,
    super.key,
  });

  final SellerAccount account;
  final VoidCallback onBack;
  final VoidCallback onContactSupport;
  final VoidCallback onRetryRegistration;

  @override
  Widget build(BuildContext context) {
    final _SellerStatusContent content = _contentFor(
      account.registrationStatus,
    );
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        key: const Key('seller_status_back'),
                        tooltip: 'Back',
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 42),
                    Icon(content.icon, color: content.accent, size: 72),
                    const SizedBox(height: 22),
                    Text(
                      content.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      account.companyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        content.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.86,
                          ),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (account.registrationStatus ==
                        SellerRegistrationStatus.rejected) ...<Widget>[
                      GlassActionButton(
                        key: const Key('seller_retry_registration'),
                        label: 'Retry Registration',
                        icon: Icons.refresh_rounded,
                        onPressed: onRetryRegistration,
                      ),
                      const SizedBox(height: 12),
                    ],
                    GlassActionButton(
                      key: const Key('seller_status_support'),
                      label: 'Contact Support',
                      icon: Icons.support_agent_rounded,
                      variant: GlassButtonVariant.secondary,
                      onPressed: onContactSupport,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static _SellerStatusContent _contentFor(SellerRegistrationStatus status) {
    return switch (status) {
      SellerRegistrationStatus.pendingApproval => const _SellerStatusContent(
        title: 'Approval Pending',
        message:
            'Your company account is still under administrator review. You can return later and sign in with the same business email to check again.',
        icon: Icons.hourglass_top_rounded,
        accent: AppColors.blue,
      ),
      SellerRegistrationStatus.rejected => const _SellerStatusContent(
        title: 'Registration Not Approved',
        message:
            'We could not approve this company registration. Review the company and license information before retrying, or contact support for guidance.',
        icon: Icons.cancel_outlined,
        accent: Color(0xFFFF8A9B),
      ),
      SellerRegistrationStatus.suspended => const _SellerStatusContent(
        title: 'Account Suspended',
        message:
            'This insurance company account is currently suspended and cannot access the company portal. Contact support for assistance.',
        icon: Icons.block_rounded,
        accent: Color(0xFFFFB36B),
      ),
      _ => const _SellerStatusContent(
        title: 'Account Unavailable',
        message:
            'This company account is not currently available. Contact support for assistance.',
        icon: Icons.info_outline_rounded,
        accent: AppColors.blue,
      ),
    };
  }
}

class _SellerStatusContent {
  const _SellerStatusContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accent;
}
