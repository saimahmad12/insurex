import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SplashBrand extends StatelessWidget {
  const SplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: <Color>[
                AppColors.blue,
                AppColors.blue,
                AppColors.blue,
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'InsureX',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 43,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 11),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SMART  •  SECURE  •  TRANSPARENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.25,
            ),
          ),
        ),
      ],
    );
  }
}
