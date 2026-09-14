import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/insurance_claim.dart';
import 'claim_formatters.dart';

class AiVerificationSummaryCard extends StatelessWidget {
  const AiVerificationSummaryCard({
    required this.claim,
    required this.requiresManualReview,
    super.key,
  });

  final InsuranceClaim claim;
  final bool requiresManualReview;

  @override
  Widget build(BuildContext context) {
    final AiVerificationResult? result = claim.aiVerificationResult;

    return GlassContainer(
      key: const Key('ai_verification_summary_card'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.blue, AppColors.blue],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI Image Analysis',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                ClaimFormatters.aiAnalysisStatus(claim.aiAnalysisStatus),
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (result == null)
            Text(
              claim.aiAnalysisStatus == AiAnalysisStatus.failed
                  ? 'The image analysis could not be completed. Your submitted evidence remains available for review.'
                  : 'Image analysis is pending. Your claim information remains available while processing continues.',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.72),
                fontSize: 12,
                height: 1.45,
              ),
            )
          else ...<Widget>[
            _AnalysisRow(
              label: 'Image authenticity',
              value: _authenticity(result.classification),
            ),
            _AnalysisRow(
              label: 'Image manipulation',
              value: _manipulation(result.classification),
            ),
            _AnalysisRow(
              label: 'AI-generated image',
              value: _aiGenerated(result.classification),
            ),
            _AnalysisRow(
              label: 'Confidence score',
              value: '${result.confidenceScore}%',
            ),
            _AnalysisRow(
              label: 'Images analysed',
              value: '${result.analysedImageCount}',
            ),
            _AnalysisRow(
              label: 'Manual review',
              value: requiresManualReview ? 'Required' : 'Standard review',
            ),
            _AnalysisRow(label: 'Model version', value: result.modelVersion),
            _AnalysisRow(
              label: 'Analysed at',
              value: ClaimFormatters.dateTime(result.analysisTimestamp),
              isLast: true,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                _message(result.classification),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _authenticity(EvidenceClassification classification) {
    return switch (classification) {
      EvidenceClassification.authentic => 'No concerns detected',
      EvidenceClassification.manipulated => 'Requires review',
      EvidenceClassification.aiGenerated => 'Requires review',
      EvidenceClassification.inconclusive => 'Inconclusive',
    };
  }

  static String _manipulation(EvidenceClassification classification) {
    return switch (classification) {
      EvidenceClassification.manipulated => 'Possible alteration',
      EvidenceClassification.inconclusive => 'Inconclusive',
      _ => 'Not detected',
    };
  }

  static String _aiGenerated(EvidenceClassification classification) {
    return switch (classification) {
      EvidenceClassification.aiGenerated => 'Requires review',
      EvidenceClassification.inconclusive => 'Inconclusive',
      _ => 'Not detected',
    };
  }

  static String _message(EvidenceClassification classification) {
    switch (classification) {
      case EvidenceClassification.authentic:
        return 'No suspicious image manipulation was detected. Your claim has been sent for review.';
      case EvidenceClassification.manipulated:
      case EvidenceClassification.aiGenerated:
        return 'The uploaded evidence requires further review. A claim officer will review your submission.';
      case EvidenceClassification.inconclusive:
        return 'The AI analysis could not reach a reliable result. Manual review is required.';
    }
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
