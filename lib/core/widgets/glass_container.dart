import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 26,
    this.blur = 14,
    this.opacity = 0.12,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.14),
              blurRadius: 24,
              spreadRadius: -3,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.28),
                  width: 1.1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const <double>[0, 0.24, 0.50, 0.76, 1],
                  colors: <Color>[
                    AppColors.white.withValues(alpha: opacity + 0.16),
                    AppColors.blue.withValues(alpha: opacity * 0.70),
                    AppColors.white.withValues(alpha: opacity + 0.02),
                    AppColors.blue.withValues(alpha: opacity * 0.45),
                    AppColors.white.withValues(alpha: opacity * 0.35),
                  ],
                ),
              ),
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
