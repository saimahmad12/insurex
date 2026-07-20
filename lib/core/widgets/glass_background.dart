import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlassBackground extends StatelessWidget {
  const GlassBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.backgroundTop,
                AppColors.backgroundMiddle,
                AppColors.backgroundBottom,
              ],
              stops: <double>[0, 0.58, 1],
            ),
          ),
        ),
        const Positioned(
          top: -130,
          left: -105,
          child: _GlowOrb(
            size: 310,
            color: AppColors.violet,
            opacity: 0.42,
          ),
        ),
        const Positioned(
          top: 170,
          right: -115,
          child: _GlowOrb(
            size: 300,
            color: AppColors.electricBlue,
            opacity: 0.42,
          ),
        ),
        const Positioned(
          bottom: -135,
          left: 35,
          child: _GlowOrb(
            size: 330,
            color: AppColors.pink,
            opacity: 0.36,
          ),
        ),
        const Positioned.fill(
          child: _SoftGridOverlay(),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.28),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftGridOverlay extends StatelessWidget {
  const _SoftGridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.018)
      ..strokeWidth = 0.8;

    const double gap = 42;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}