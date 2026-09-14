import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/additional_evidence_request.dart';
import 'claim_formatters.dart';

class AdditionalEvidenceRequestCard extends StatelessWidget {
  const AdditionalEvidenceRequestCard({
    required this.request,
    required this.onUploadEvidence,
    super.key,
  });

  final AdditionalEvidenceRequest request;
  final VoidCallback onUploadEvidence;

  @override
  Widget build(BuildContext context) {
    const Color warning = Color(0xFFFFB84A);

    return GlassContainer(
      key: const Key('additional_evidence_request_card'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.add_photo_alternate_outlined, color: warning),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Additional Evidence Required',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            request.title,
            style: const TextStyle(
              color: warning,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            request.reason,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _EvidenceDate(
            label: 'Requested',
            value: ClaimFormatters.dateTime(request.requestedAt),
          ),
          if (request.submissionDeadline != null)
            _EvidenceDate(
              label: 'Submission deadline',
              value: ClaimFormatters.date(request.submissionDeadline!),
            ),
          const SizedBox(height: 15),
          Semantics(
            label: 'Upload Additional Evidence',
            button: true,
            child: ExcludeSemantics(
              child: GlassActionButton(
                key: const Key('upload_additional_evidence_button'),
                label: 'Upload Evidence',
                onPressed: onUploadEvidence,
                variant: GlassButtonVariant.secondary,
                icon: Icons.upload_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceDate extends StatelessWidget {
  const _EvidenceDate({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
