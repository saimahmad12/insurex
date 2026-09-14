import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class SignupLogo extends StatelessWidget {
  const SignupLogo({
    super.key,
    this.width = 170,
    this.height = 170,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'InsureX create account logo',
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.blue.withValues(
                alpha: 0.30,
              ),
              blurRadius: 38,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppColors.blue.withValues(
                alpha: 0.20,
              ),
              blurRadius: 52,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Image.asset(
          AppAssets.insureXSignupLogo,
          width: width,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            return const _SignupLogoFallback();
          },
        ),
      ),
    );
  }
}

class _SignupLogoFallback extends StatelessWidget {
  const _SignupLogoFallback();

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
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue,
            blurRadius: 24,
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.shield_rounded,
            color: AppColors.white,
            size: 68,
          ),
          Positioned(
            right: 14,
            bottom: 13,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.blue,
              child: Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
