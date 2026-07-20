import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class InsureXLogo extends StatelessWidget {
  const InsureXLogo({
    super.key,
    this.size = 235,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'InsureX shield logo',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _OrbitPainter(),
              ),
            ),
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.violet.withValues(
                      alpha: 0.42,
                    ),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.blue.withValues(
                      alpha: 0.22,
                    ),
                    blurRadius: 58,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  AppAssets.insureXShieldLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.verified_user_rounded,
                      size: 120,
                      color: AppColors.white,
                    );
                  },
                ),
              ),
            ),
            const Positioned(
              top: 18,
              right: 14,
              child: _OrbitIcon(
                icon: Icons.lock_outline_rounded,
              ),
            ),
            const Positioned(
              top: 78,
              left: -2,
              child: _OrbitIcon(
                icon: Icons.auto_awesome_rounded,
              ),
            ),
            const Positioned(
              right: -2,
              bottom: 48,
              child: _OrbitIcon(
                icon: Icons.description_outlined,
              ),
            ),
            const Positioned(
              left: 17,
              bottom: 13,
              child: _OrbitIcon(
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitIcon extends StatelessWidget {
  const _OrbitIcon({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.48),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.white.withValues(alpha: 0.24),
            AppColors.violet.withValues(alpha: 0.22),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.22),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: AppColors.white,
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    final Paint orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.blue.withValues(alpha: 0.32);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 11);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.98,
        height: size.height * 0.48,
      ),
      orbitPaint,
    );

    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 7);

    orbitPaint.color =
        AppColors.pink.withValues(alpha: 0.24);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.88,
        height: size.height * 0.58,
      ),
      orbitPaint,
    );

    canvas.restore();

    final Paint dotPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.75);

    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.52),
      2,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.79, size.height * 0.32),
      2,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.73, size.height * 0.76),
      2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}