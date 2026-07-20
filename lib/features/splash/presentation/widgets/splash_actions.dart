import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';

class SplashActions extends StatelessWidget {
  const SplashActions({
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GlassActionButton(
          label: 'Get Started',
          icon: Icons.arrow_forward_rounded,
          onPressed: onGetStarted,
        ),
        const SizedBox(height: 13),
        GlassActionButton(
          label: 'Login',
          variant: GlassButtonVariant.secondary,
          onPressed: onLogin,
        ),
        const SizedBox(height: 18),
        Text(
          'Protected by AI and blockchain technology',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(
              alpha: 0.68,
            ),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}