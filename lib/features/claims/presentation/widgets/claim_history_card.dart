import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/fraud_risk_level.dart';
import '../../domain/entities/insurance_claim.dart';
import 'claim_formatters.dart';
import 'claim_status_badge.dart';

class ClaimHistoryCard extends StatelessWidget {
  const ClaimHistoryCard({
    required this.claim,
    required this.onPressed,
    super.key,
  });

  final InsuranceClaim claim;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final FraudRiskLevel riskLevel = fraudRiskLevelForScore(
      claim.aiVerificationResult?.fraudRiskScore,
    );

    return GlassContainer(
      key: ValueKey<String>('claim_card_${claim.id}'),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(17),
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
                            claim.id,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${claim.policyName} • ${claim.policyNumber}',
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.58,
                              ),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClaimStatusBadge(status: claim.status),
                  ],
                ),
                const SizedBox(height: 15),
                _DetailRow(
                  label: 'Incident',
                  value: ClaimFormatters.incidentType(claim.incidentType),
                ),
                _DetailRow(
                  label: 'Incident date',
                  value: ClaimFormatters.date(claim.incidentDate),
                ),
                _DetailRow(
                  label: 'Submitted',
                  value: ClaimFormatters.date(claim.submittedAt),
                ),
                _DetailRow(
                  label: 'Estimated amount',
                  value: ClaimFormatters.amount(claim.estimatedClaimAmount),
                ),
                if (claim.approvedAmount != null)
                  _DetailRow(
                    label: 'Approved amount',
                    value: ClaimFormatters.amount(claim.approvedAmount!),
                  ),
                if (claim.status == ClaimStatus.rejected &&
                    claim.decision?.reason != null)
                  _DetailRow(
                    label: 'Reason',
                    value: claim.decision!.reason!,
                    maxLines: 2,
                  ),
                if (claim.decision != null)
                  _DetailRow(
                    label: 'Decision date',
                    value: ClaimFormatters.date(claim.decision!.decidedAt),
                  ),
                if (claim.status == ClaimStatus.settled &&
                    claim.payment != null) ...<Widget>[
                  _DetailRow(
                    label: 'Paid amount',
                    value: ClaimFormatters.amount(claim.payment!.amount),
                  ),
                  if (claim.payment!.paidAt != null)
                    _DetailRow(
                      label: 'Settlement date',
                      value: ClaimFormatters.date(claim.payment!.paidAt!),
                    ),
                ],
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  children: <Widget>[
                    _CompactLabel(
                      icon: Icons.auto_awesome_outlined,
                      text: ClaimFormatters.aiAnalysisStatus(
                        claim.aiAnalysisStatus,
                      ),
                    ),
                    _CompactLabel(
                      icon: Icons.shield_outlined,
                      text: ClaimFormatters.fraudRiskLevel(riskLevel),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Text(
                      'Updated ${ClaimFormatters.date(claim.lastUpdatedAt)}',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.48),
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.blue,
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactLabel extends StatelessWidget {
  const _CompactLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.blue, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
