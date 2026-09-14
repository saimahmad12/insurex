import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/seller_dashboard_controller.dart';
import '../../domain/entities/seller_dashboard.dart';
import '../widgets/seller_dashboard_header.dart';
import '../widgets/seller_dashboard_sections.dart';
import '../widgets/seller_dashboard_state_view.dart';
import '../widgets/seller_dashboard_summary_grid.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({
    required this.controller,
    required this.onNotifications,
    required this.onReturnToLogin,
    super.key,
  });

  final SellerDashboardController controller;
  final VoidCallback onNotifications;
  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return switch (controller.status) {
              SellerDashboardStatus.accountUnavailable =>
                SellerDashboardStateView(
                  key: const Key('seller_dashboard_account_unavailable'),
                  icon: Icons.business_outlined,
                  title: 'Seller account unavailable',
                  message:
                      'Sign in with an approved insurance company account to open this dashboard.',
                  actionLabel: 'Return to Login',
                  onAction: onReturnToLogin,
                ),
              SellerDashboardStatus.accountNotApproved =>
                SellerDashboardStateView(
                  key: const Key('seller_dashboard_not_approved'),
                  icon: Icons.gpp_maybe_outlined,
                  title: 'Seller account not approved',
                  message:
                      'This dashboard is available only after the insurance company account has been approved.',
                  actionLabel: 'Return to Login',
                  onAction: onReturnToLogin,
                ),
              SellerDashboardStatus.initial ||
              SellerDashboardStatus.loading => const SellerDashboardStateView(
                icon: Icons.dashboard_outlined,
                title: 'Loading seller dashboard',
                message: 'Preparing synthetic company performance data.',
                isLoading: true,
              ),
              SellerDashboardStatus.failure => SellerDashboardStateView(
                key: const Key('seller_dashboard_error'),
                icon: Icons.error_outline_rounded,
                title: 'Dashboard unavailable',
                message:
                    controller.errorMessage ??
                    'Unable to load the seller dashboard.',
                actionLabel: 'Retry',
                onAction: controller.loadDashboard,
              ),
              SellerDashboardStatus.loaded ||
              SellerDashboardStatus.empty ||
              SellerDashboardStatus.refreshing => _DashboardContent(
                controller: controller,
                onNotifications: onNotifications,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.controller,
    required this.onNotifications,
  });

  final SellerDashboardController controller;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final SellerDashboardAccount account = controller.account!;
    final SellerDashboard dashboard = controller.dashboard!;
    final bool isEmpty = controller.status == SellerDashboardStatus.empty;

    return RefreshIndicator(
      color: AppColors.blue,
      backgroundColor: AppColors.backgroundMiddle,
      onRefresh: controller.refreshDashboard,
      child: SingleChildScrollView(
        key: const Key('seller_dashboard_scroll'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SellerDashboardHeader(
                  account: account,
                  onNotifications: onNotifications,
                  onRefresh: controller.refreshDashboard,
                  isRefreshing: controller.isRefreshing,
                ),
                if (controller.isRefreshing) ...<Widget>[
                  const SizedBox(height: 13),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      key: Key('seller_dashboard_refreshing'),
                      minHeight: 3,
                      color: AppColors.blue,
                      backgroundColor: AppColors.glassSurface,
                    ),
                  ),
                ],
                if (!controller.isRefreshing &&
                    controller.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 13),
                  SellerDashboardRefreshError(
                    message: controller.errorMessage!,
                    onRetry: controller.refreshDashboard,
                  ),
                ],
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Company Summary'),
                const SizedBox(height: 12),
                SellerDashboardSummaryGrid(summary: dashboard.summary),
                const SizedBox(height: 25),
                if (isEmpty) ...<Widget>[
                  const SellerDashboardEmptyState(),
                ] else ...<Widget>[
                  SellerRecentApplicationsSection(
                    applications: dashboard.recentApplications,
                  ),
                  const SizedBox(height: 14),
                  SellerRecentClaimsSection(claims: dashboard.recentClaims),
                  const SizedBox(height: 14),
                  SellerSalesOverviewCard(points: dashboard.salesOverview),
                  const SizedBox(height: 14),
                  SellerPolicyCategoryPerformanceCard(
                    categories: dashboard.categoryPerformance,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
