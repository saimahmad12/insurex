import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ClaimStatusHeader extends StatelessWidget {
  const ClaimStatusHeader({
    required this.onBack,
    required this.onRefresh,
    required this.isRefreshing,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          key: const Key('claim_status_back_button'),
          tooltip: 'Back',
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white.withValues(alpha: 0.08),
            side: BorderSide(color: AppColors.white.withValues(alpha: 0.16)),
          ),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        ),
        const Expanded(
          child: Text(
            'Claim Status',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: isRefreshing
              ? const Center(
                  child: SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.blue,
                    ),
                  ),
                )
              : IconButton(
                  key: const Key('claim_status_refresh_button'),
                  tooltip: 'Refresh claim status',
                  onPressed: onRefresh,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.white,
                  ),
                ),
        ),
      ],
    );
  }
}
