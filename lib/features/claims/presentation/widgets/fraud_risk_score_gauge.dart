import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/fraud_risk_level.dart';
import 'claim_formatters.dart';

class FraudRiskScoreGauge extends StatelessWidget {
  const FraudRiskScoreGauge({
    required this.score,
    required this.riskLevel,
    required this.analysisCompleted,
    super.key,
  });

  final double? score;
  final FraudRiskLevel riskLevel;
  final bool analysisCompleted;

  @override
  Widget build(BuildContext context) {
    final double clampedScore = clampFraudRiskScore(score ?? 0);
    final Color riskColor = _riskColor(riskLevel);
    final String riskLabel = ClaimFormatters.fraudRiskLevel(riskLevel);
    final String scoreLabel = analysisCompleted
        ? '${clampedScore.round()}%'
        : '--';

    return Semantics(
      key: const Key('fraud_risk_score_semantics'),
      label: analysisCompleted
          ? 'Fraud risk score ${clampedScore.round()} percent, $riskLabel'
          : 'Fraud risk score, analysis pending',
      container: true,
      child: GlassContainer(
        key: const Key('fraud_risk_score_gauge'),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fraud Risk Score',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: analysisCompleted ? clampedScore / 100 : 0,
              ),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double progress, Widget? child) {
                return SizedBox(
                  width: 142,
                  height: 142,
                  child: CustomPaint(
                    painter: _FraudRiskPainter(
                      progress: progress,
                      trackColor: AppColors.white.withValues(alpha: 0.10),
                      riskColor: riskColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            scoreLabel,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            riskLabel,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Color _riskColor(FraudRiskLevel riskLevel) {
    switch (riskLevel) {
      case FraudRiskLevel.low:
        return const Color(0xFF49E6A4);
      case FraudRiskLevel.medium:
        return const Color(0xFFFFB84A);
      case FraudRiskLevel.high:
        return const Color(0xFFFF718A);
      case FraudRiskLevel.pending:
        return AppColors.textSecondary;
    }
  }
}

class _FraudRiskPainter extends CustomPainter {
  const _FraudRiskPainter({
    required this.progress,
    required this.trackColor,
    required this.riskColor,
  });

  final double progress;
  final Color trackColor;
  final Color riskColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect arcRect = Offset.zero & size;
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    final Paint riskPaint = Paint()
      ..color = riskColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect.deflate(7),
      -math.pi / 2,
      math.pi * 2,
      false,
      trackPaint,
    );
    canvas.drawArc(
      arcRect.deflate(7),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      riskPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FraudRiskPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        trackColor != oldDelegate.trackColor ||
        riskColor != oldDelegate.riskColor;
  }
}
