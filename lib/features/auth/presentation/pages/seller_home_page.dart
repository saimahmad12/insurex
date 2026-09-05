import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/seller_authentication.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({
    required this.account,
    required this.onReturnToLogin,
    required this.onContactSupport,
    super.key,
  });

  final SellerAccount account;
  final VoidCallback onReturnToLogin;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 48, 22, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.business_center_rounded,
                      color: AppColors.blue,
                      size: 76,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Welcome to the Seller Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      account.companyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.pink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.construction_rounded,
                            color: AppColors.violet,
                            size: 38,
                          ),
                          const SizedBox(height: 13),
                          const Text(
                            'Seller dashboard coming separately',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your approved company account is authenticated. Policy management and the complete seller dashboard are outside this authentication release.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.82,
                              ),
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    GlassActionButton(
                      key: const Key('seller_home_return_login'),
                      label: 'Return to Login',
                      icon: Icons.logout_rounded,
                      onPressed: onReturnToLogin,
                    ),
                    const SizedBox(height: 12),
                    GlassActionButton(
                      key: const Key('seller_home_support'),
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
