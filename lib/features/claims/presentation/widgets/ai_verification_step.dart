import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/file_claim_controller.dart';
import '../../domain/entities/ai_verification_result.dart';
import 'claim_formatters.dart';

class AiVerificationStep extends StatelessWidget {
  const AiVerificationStep({
    required this.state,
    required this.stage,
    required this.imageCount,
    required this.onVerify,
    required this.onRetry,
    super.key,
    this.result,
    this.errorMessage,
  });

  final AiVerificationState state;
  final VerificationProgressStage stage;
  final int imageCount;
  final VoidCallback onVerify;
  final VoidCallback onRetry;
  final AiVerificationResult? result;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('ai_verification_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'InsureX will analyse the incident images before submission.',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: state == AiVerificationState.verified && result != null
              ? _VerificationResult(result: result!)
              : state == AiVerificationState.failed
              ? _VerificationFailure(
                  message:
                      errorMessage ??
                      'Image could not be verified. Please retry.',
                  onRetry: onRetry,
                )
              : _VerificationProgress(
                  state: state,
                  stage: stage,
                  imageCount: imageCount,
                ),
        ),
        if (state == AiVerificationState.idle) ...<Widget>[
          const SizedBox(height: 16),
          GlassActionButton(
            key: const Key('verify_images_button'),
            label: 'Verify Images',
            onPressed: onVerify,
            icon: Icons.auto_awesome_outlined,
          ),
        ],
        const SizedBox(height: 13),
        Text(
          'AI verification supports claim review and never automatically rejects a claim. Suspicious or inconclusive evidence is sent for manual review.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.53),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _VerificationProgress extends StatelessWidget {
  const _VerificationProgress({
    required this.state,
    required this.stage,
    required this.imageCount,
  });

  final AiVerificationState state;
  final VerificationProgressStage stage;
  final int imageCount;

  static const List<(VerificationProgressStage, String)> _stages =
      <(VerificationProgressStage, String)>[
        (VerificationProgressStage.uploading, 'Uploading incident images'),
        (VerificationProgressStage.analysing, 'Analysing incident evidence'),
        (VerificationProgressStage.authenticity, 'Checking image authenticity'),
        (
          VerificationProgressStage.manipulation,
          'Detecting possible manipulation',
        ),
        (VerificationProgressStage.risk, 'Calculating fraud-risk score'),
        (VerificationProgressStage.completed, 'Verification completed'),
      ];

  @override
  Widget build(BuildContext context) {
    if (state == AiVerificationState.idle) {
      return Column(
        children: <Widget>[
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[AppColors.violet, AppColors.blue],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ready for AI verification',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$imageCount uploaded ${imageCount == 1 ? 'image' : 'images'} ready for analysis',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.65),
              fontSize: 12.5,
            ),
          ),
        ],
      );
    }

    final int activeIndex = _stages.indexWhere(
      ((VerificationProgressStage, String) item) => item.$1 == stage,
    );

    return Column(
      key: const Key('verification_progress'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verifying incident evidence',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (int index = 0; index < _stages.length; index++) ...<Widget>[
          _ProgressStageRow(
            label: _stages[index].$2,
            complete: index < activeIndex,
            active: index == activeIndex,
          ),
          if (index != _stages.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ProgressStageRow extends StatelessWidget {
  const _ProgressStageRow({
    required this.label,
    required this.complete,
    required this.active,
  });

  final String label;
  final bool complete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color color = complete
        ? const Color(0xFF49E6A4)
        : active
        ? AppColors.blue
        : AppColors.textSecondary.withValues(alpha: 0.35);

    return Row(
      children: <Widget>[
        Icon(
          complete ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationResult extends StatelessWidget {
  const _VerificationResult({required this.result});

  final AiVerificationResult result;

  @override
  Widget build(BuildContext context) {
    final bool manualReview =
        result.requiresManualReview ||
        result.classification != EvidenceClassification.authentic;
    final Color statusColor = manualReview
        ? const Color(0xFFFFC56E)
        : const Color(0xFF49E6A4);

    return Column(
      key: const Key('verification_result'),
      children: <Widget>[
        Icon(
          manualReview
              ? Icons.rate_review_outlined
              : Icons.verified_user_rounded,
          color: statusColor,
          size: 52,
        ),
        const SizedBox(height: 13),
        Text(
          ClaimFormatters.evidenceClassification(result.classification),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          manualReview
              ? 'Your evidence will be reviewed by a claims specialist.'
              : 'The incident evidence passed the initial authenticity review.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(
              child: _Score(
                label: 'Risk score',
                value: '${result.fraudRiskScore}/100',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Score(
                label: 'Confidence',
                value: '${result.confidenceScore}%',
              ),
            ),
          ],
        ),
        if (manualReview) ...<Widget>[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              'Manual review required',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationFailure extends StatelessWidget {
  const _VerificationFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('verification_failure'),
      children: <Widget>[
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFFF8A9B),
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Image could not be verified',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 13),
        TextButton.icon(
          key: const Key('retry_verification_button'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry Verification'),
        ),
      ],
    );
  }
}
