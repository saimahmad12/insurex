import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/seller_registration.dart';

class SellerRegistrationSubmittedPage extends StatelessWidget {
  const SellerRegistrationSubmittedPage({
    required this.result,
    required this.onBack,
    required this.onReturnToLogin,
    required this.onContactSupport,
    super.key,
  });

  final SellerRegistrationResult result;
  final VoidCallback onBack;
  final VoidCallback onReturnToLogin;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
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
                        key: const Key('seller_submitted_back'),
                        tooltip: 'Back',
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[AppColors.blue, AppColors.violet],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.45),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: AppColors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Seller Registration Submitted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your insurance company registration is pending administrator approval.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.82),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.blue,
                            size: 30,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'What happens next?',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'An administrator will review the company registration and insurance license details. Use the business email to check the account status later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.80,
                              ),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          if (result.referenceNumber != null) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              'Reference: ${result.referenceNumber}',
                              key: const Key('seller_registration_reference'),
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    GlassActionButton(
                      key: const Key('seller_submitted_login'),
                      label: 'Return to Login',
                      icon: Icons.login_rounded,
                      onPressed: onReturnToLogin,
                    ),
                    const SizedBox(height: 12),
                    GlassActionButton(
                      key: const Key('seller_submitted_support'),
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
}
