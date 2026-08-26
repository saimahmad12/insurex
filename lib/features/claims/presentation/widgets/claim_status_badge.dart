import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/claim_submission_result.dart';
import 'claim_formatters.dart';

class ClaimStatusBadge extends StatelessWidget {
  const ClaimStatusBadge({required this.status, super.key});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      ClaimStatus.approved || ClaimStatus.settled => const Color(0xFF49E6A4),
      ClaimStatus.rejected => const Color(0xFFFF718A),
      ClaimStatus.additionalEvidenceRequired => const Color(0xFFFFB84A),
      _ => AppColors.blue,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        ClaimFormatters.claimStatus(status),
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
