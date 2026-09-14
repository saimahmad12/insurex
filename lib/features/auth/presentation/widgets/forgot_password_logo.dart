import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordLogo extends StatelessWidget {
  const ForgotPasswordLogo({
    super.key,
    this.size = 160,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'InsureX password recovery logo',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _LogoGlow(
              size: size * 0.86,
            ),
            Image.asset(
              AppAssets.forgotPasswordLogo,
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                  ) {
                return const _LogoFallback();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoGlow extends StatelessWidget {
  const _LogoGlow({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(
              alpha: 0.28,
            ),
            blurRadius: 45,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.blue.withValues(
              alpha: 0.28,
            ),
            blurRadius: 55,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: AppColors.blue.withValues(
              alpha: 0.16,
            ),
            blurRadius: 65,
          ),
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.blue,
            AppColors.blue,
            AppColors.blue,
          ],
        ),
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        color: AppColors.white,
        size: 62,
      ),
    );
  }
}
