import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.child,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final Widget child;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(17);

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 66,
        height: 54,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AppColors.white.withValues(
                      alpha: 0.20,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.white.withValues(
                        alpha: 0.06,
                      ),
                      AppColors.white.withValues(
                        alpha: 0.02,
                      ),
                    ],
                  ),
                ),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: borderRadius,
                  child: Center(
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}