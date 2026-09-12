import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_container.dart';

class SellerDashboardStateView extends StatelessWidget {
  const SellerDashboardStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: GlassContainer(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading)
                  const SizedBox(
                    key: Key('seller_dashboard_loading'),
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      color: AppColors.blue,
                      strokeWidth: 3,
                    ),
                  )
                else
                  Icon(icon, color: AppColors.blue, size: 46),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.78),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 21),
                  GlassActionButton(
                    key: const Key('seller_dashboard_state_action'),
                    label: actionLabel!,
                    onPressed: onAction,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SellerDashboardEmptyState extends StatelessWidget {
  const SellerDashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('seller_dashboard_empty'),
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            color: AppColors.textSecondary.withValues(alpha: 0.58),
            size: 42,
          ),
          const SizedBox(height: 13),
          const Text(
            'No dashboard activity yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Synthetic applications, policies, claims, and sales will appear here when data is available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.68),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class SellerDashboardRefreshError extends StatelessWidget {
  const SellerDashboardRefreshError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('seller_dashboard_refresh_error'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.pink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }
}
