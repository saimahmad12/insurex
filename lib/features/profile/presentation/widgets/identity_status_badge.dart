import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/identity_verification.dart';

class IdentityStatusBadge extends StatelessWidget {
  const IdentityStatusBadge({required this.status, super.key});

  final IdentityVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = identityStatusColor(status);
    return Container(
      key: const Key('identity_status_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(identityStatusIcon(status), color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            identityStatusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String identityStatusLabel(IdentityVerificationStatus status) {
  return switch (status) {
    IdentityVerificationStatus.notStarted => 'Not Verified',
    IdentityVerificationStatus.pending => 'Verification Pending',
    IdentityVerificationStatus.verified => 'Identity Verified',
    IdentityVerificationStatus.rejected => 'Verification Rejected',
  };
}

Color identityStatusColor(IdentityVerificationStatus status) {
  return switch (status) {
    IdentityVerificationStatus.verified => const Color(0xFF49E6A4),
    IdentityVerificationStatus.pending => const Color(0xFFFFB84A),
    IdentityVerificationStatus.rejected => const Color(0xFFFF718A),
    IdentityVerificationStatus.notStarted => AppColors.textSecondary,
  };
}

IconData identityStatusIcon(IdentityVerificationStatus status) {
  return switch (status) {
    IdentityVerificationStatus.verified => Icons.verified_user_outlined,
    IdentityVerificationStatus.pending => Icons.schedule_rounded,
    IdentityVerificationStatus.rejected => Icons.error_outline_rounded,
    IdentityVerificationStatus.notStarted => Icons.shield_outlined,
  };
}
