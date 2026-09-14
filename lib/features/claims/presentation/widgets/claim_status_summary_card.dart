import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/insurance_claim.dart';
import 'claim_formatters.dart';
import 'claim_status_badge.dart';

class ClaimStatusSummaryCard extends StatelessWidget {
  const ClaimStatusSummaryCard({required this.claim, super.key});

  final InsuranceClaim claim;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claim_status_summary_card'),
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Claim ID',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.55),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      claim.id,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClaimStatusBadge(status: claim.status),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Policy', value: claim.policyName),
          _SummaryRow(label: 'Policy number', value: claim.policyNumber),
          _SummaryRow(
            label: 'Incident',
            value: ClaimFormatters.incidentType(claim.incidentType),
          ),
          _SummaryRow(
            label: 'Incident date',
            value: ClaimFormatters.date(claim.incidentDate),
          ),
          _SummaryRow(
            label: 'Submitted',
            value: ClaimFormatters.dateTime(claim.submittedAt),
          ),
          _SummaryRow(
            label: 'Estimated amount',
            value: ClaimFormatters.amount(claim.estimatedClaimAmount),
          ),
          if (claim.approvedAmount != null)
            _SummaryRow(
              label: 'Approved amount',
              value: ClaimFormatters.amount(claim.approvedAmount!),
              isLast: true,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.55),
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
