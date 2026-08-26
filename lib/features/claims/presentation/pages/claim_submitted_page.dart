import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../widgets/claim_formatters.dart';

class ClaimSubmittedPage extends StatelessWidget {
  const ClaimSubmittedPage({
    required this.result,
    required this.onTrackClaim,
    required this.onReturnToDashboard,
    super.key,
  });

  final ClaimSubmissionResult result;
  final VoidCallback onTrackClaim;
  final VoidCallback onReturnToDashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF49E6A4), AppColors.blue],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(
                              0xFF49E6A4,
                            ).withValues(alpha: 0.35),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Claim submitted successfully',
                      key: Key('claim_submitted_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your claim is ready for initial review. Keep the claim ID for tracking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.72),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassContainer(
                      padding: const EdgeInsets.all(19),
                      child: Column(
                        children: <Widget>[
                          _ResultRow(label: 'Claim ID', value: result.claimId),
                          _ResultRow(
                            label: 'Submitted',
                            value: ClaimFormatters.dateTime(result.submittedAt),
                          ),
                          _ResultRow(
                            label: 'AI verification',
                            value: result.aiVerificationCompleted
                                ? 'Completed'
                                : 'Pending',
                          ),
                          _ResultRow(
                            label: 'Status',
                            value: ClaimFormatters.claimStatus(result.status),
                          ),
                          _ResultRow(
                            label: 'Blockchain record',
                            value: result.blockchainRecordStatus,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    GlassActionButton(
                      label: 'Track Claim',
                      onPressed: onTrackClaim,
                      icon: Icons.timeline_rounded,
                    ),
                    const SizedBox(height: 11),
                    GlassActionButton(
                      key: const Key('return_to_dashboard_button'),
                      label: 'Return to Dashboard',
                      onPressed: onReturnToDashboard,
                      variant: GlassButtonVariant.secondary,
                      icon: Icons.home_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.58),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...<Widget>[
          const SizedBox(height: 12),
          Divider(color: AppColors.white.withValues(alpha: 0.075)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
