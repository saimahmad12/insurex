import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum GlassButtonVariant {
  primary,
  secondary,
}

class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary =
        variant == GlassButtonVariant.primary;

    final bool isEnabled =
        onPressed != null && !isLoading;

    final BorderRadius borderRadius =
    BorderRadius.circular(18);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled || isLoading ? 1 : 0.55,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 14,
              sigmaY: 14,
            ),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: AppColors.white.withValues(
                      alpha: isPrimary ? 0.34 : 0.58,
                    ),
                  ),
                  gradient: isPrimary
                      ? const LinearGradient(
                    colors: <Color>[
                      AppColors.blue,
                      AppColors.violet,
                      AppColors.pink,
                    ],
                  )
                      : LinearGradient(
                    colors: <Color>[
                      AppColors.white.withValues(
                        alpha: 0.13,
                      ),
                      AppColors.white.withValues(
                        alpha: 0.045,
                      ),
                    ],
                  ),
                  boxShadow: isPrimary
                      ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.violet.withValues(
                        alpha: 0.40,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                      : null,
                ),
                child: InkWell(
                  onTap: isEnabled ? onPressed : null,
                  borderRadius: borderRadius,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.white,
                      ),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (icon != null) ...<Widget>[
                          const SizedBox(width: 10),
                          Icon(
                            icon,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
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