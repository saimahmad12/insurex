import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_decision.dart';
import 'claim_formatters.dart';

class ClaimDecisionCard extends StatelessWidget {
  const ClaimDecisionCard({
    required this.decision,
    required this.onContactSupport,
    super.key,
  });

  final ClaimDecision decision;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    final bool approved = decision.outcome == ClaimDecisionOutcome.approved;
    final Color accent = approved
        ? const Color(0xFF49E6A4)
        : const Color(0xFFFF718A);

    return GlassContainer(
      key: const Key('claim_decision_card'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                approved ? Icons.verified_rounded : Icons.info_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  approved ? 'Claim Approved' : 'Claim Rejected',
                  style: TextStyle(
                    color: accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (decision.approvedAmount != null)
            _DecisionRow(
              label: 'Approved amount',
              value: ClaimFormatters.amount(decision.approvedAmount!),
            ),
          if (decision.reason != null)
            _DecisionRow(label: 'Reason', value: decision.reason!),
          _DecisionRow(
            label: 'Decision date',
            value: ClaimFormatters.dateTime(decision.decidedAt),
          ),
          const SizedBox(height: 3),
          Text(
            decision.message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          if (!approved) ...<Widget>[
            const SizedBox(height: 16),
            GlassActionButton(
              label: 'Contact Support',
              onPressed: onContactSupport,
              variant: GlassButtonVariant.secondary,
              icon: Icons.support_agent_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionRow extends StatelessWidget {
  const _DecisionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            flex: 2,
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
