import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/claim_image.dart';
import '../../domain/entities/claim_policy.dart';
import '../../domain/entities/incident_details.dart';
import 'claim_formatters.dart';

class ClaimReviewStep extends StatelessWidget {
  const ClaimReviewStep({
    required this.policy,
    required this.incidentDetails,
    required this.images,
    required this.verificationResult,
    required this.declarationAccepted,
    required this.aiConsentAccepted,
    required this.onDeclarationChanged,
    required this.onAiConsentChanged,
    required this.onEditPolicy,
    required this.onEditIncident,
    required this.onEditImages,
    super.key,
    this.errorMessage,
  });

  final ClaimPolicy policy;
  final IncidentDetails incidentDetails;
  final List<ClaimImage> images;
  final AiVerificationResult verificationResult;
  final bool declarationAccepted;
  final bool aiConsentAccepted;
  final ValueChanged<bool> onDeclarationChanged;
  final ValueChanged<bool> onAiConsentChanged;
  final VoidCallback onEditPolicy;
  final VoidCallback onEditIncident;
  final VoidCallback onEditImages;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('claim_review_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Review all information before submitting your claim.',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        _ReviewCard(
          title: 'Selected Policy',
          onEdit: onEditPolicy,
          children: <Widget>[
            _ReviewValue(label: 'Policy', value: policy.name),
            _ReviewValue(label: 'Policy number', value: policy.policyNumber),
            _ReviewValue(label: 'Coverage', value: policy.coverageType),
          ],
        ),
        const SizedBox(height: 13),
        _ReviewCard(
          title: 'Incident Details',
          onEdit: onEditIncident,
          children: <Widget>[
            _ReviewValue(
              label: 'Type',
              value: ClaimFormatters.incidentType(
                incidentDetails.incidentType!,
              ),
            ),
            _ReviewValue(
              label: 'Date & time',
              value: ClaimFormatters.dateTime(incidentDetails.occurredAt!),
            ),
            _ReviewValue(label: 'Location', value: incidentDetails.location),
            _ReviewValue(label: 'Title', value: incidentDetails.title),
            _ReviewValue(
              label: 'Description',
              value: incidentDetails.description,
            ),
            _ReviewValue(
              label: 'Estimated loss',
              value: ClaimFormatters.amount(incidentDetails.estimatedLoss!),
            ),
          ],
        ),
        const SizedBox(height: 13),
        _ReviewCard(
          title: 'Incident Images',
          onEdit: onEditImages,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images
                  .map(
                    (ClaimImage image) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.image_outlined,
                            color: AppColors.blue,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            image.fileName,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 13),
        _ReviewCard(
          title: 'AI Image Verification',
          children: <Widget>[
            _ReviewValue(
              label: 'Status',
              value: ClaimFormatters.evidenceClassification(
                verificationResult.classification,
              ),
            ),
            _ReviewValue(
              label: 'Manual review',
              value:
                  verificationResult.requiresManualReview ||
                      verificationResult.classification !=
                          EvidenceClassification.authentic
                  ? 'Required'
                  : 'Not currently required',
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(13),
          child: Column(
            children: <Widget>[
              CheckboxListTile(
                key: const Key('claim_declaration_checkbox'),
                value: declarationAccepted,
                onChanged: (bool? value) =>
                    onDeclarationChanged(value ?? false),
                activeColor: AppColors.blue,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I confirm that the information and images provided are accurate and relate to this incident.',
                  style: TextStyle(color: Colors.black87, fontSize: 12.5),
                ),
              ),
              Divider(color: AppColors.white.withValues(alpha: 0.08)),
              CheckboxListTile(
                key: const Key('claim_ai_consent_checkbox'),
                value: aiConsentAccepted,
                onChanged: (bool? value) => onAiConsentChanged(value ?? false),
                activeColor: AppColors.blue,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I consent to AI image analysis and secure claim-record storage.',
                  style: TextStyle(color: Colors.black87, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            key: const Key('submission_error'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB3261E), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.children, this.onEdit});

  final String title;
  final List<Widget> children;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: 7),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewValue extends StatelessWidget {
  const _ReviewValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.56),
                fontSize: 11.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
