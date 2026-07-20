import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class AuthShieldLogo extends StatelessWidget {
  const AuthShieldLogo({
    super.key,
    this.size = 112,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'InsureX secure login logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.violet.withValues(
                alpha: 0.42,
              ),
              blurRadius: 38,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: AppColors.blue.withValues(
                alpha: 0.22,
              ),
              blurRadius: 52,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Image.asset(
          AppAssets.insureXShieldLogo,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            return const Icon(
              Icons.verified_user_rounded,
              size: 72,
              color: AppColors.white,
            );
          },
        ),
      ),
    );
  }
}