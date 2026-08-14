import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/dashboard_controller.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../widgets/blockchain_security_card.dart';
import '../widgets/dashboard_bottom_navigation.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_overview_card.dart';
import '../widgets/quick_actions_grid.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.controller,
    required this.onPolicies,
    required this.onFileClaim,
    required this.onClaimStatus,
    required this.onPayments,
    required this.onNotifications,
    required this.onClaims,
    required this.onProfile,
    super.key,
  });

  final DashboardController controller;

  final VoidCallback onPolicies;
  final VoidCallback onFileClaim;
  final VoidCallback onClaimStatus;
  final VoidCallback onPayments;
  final VoidCallback onNotifications;
  final VoidCallback onClaims;
  final VoidCallback onProfile;

  @override
  State<DashboardPage> createState() {
    return _DashboardPageState();
  }
}

class _DashboardPageState
    extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    widget.controller.loadDashboard();
  }

  @override
  void dispose() {
    widget.controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (
                BuildContext context,
                Widget? child,
                ) {
              if (widget.controller.isLoading &&
                  widget.controller.summary ==
                      null) {
                return const Center(
                  child:
                  CircularProgressIndicator(
                    color: AppColors.blue,
                  ),
                );
              }

              final DashboardSummary? summary =
                  widget.controller.summary;

              if (summary == null) {
                return _DashboardError(
                  message:
                  widget.controller.errorMessage ??
                      'Unable to load dashboard.',
                  onRetry:
                  widget.controller.loadDashboard,
                );
              }

              return RefreshIndicator(
                color: AppColors.blue,
                onRefresh: widget
                    .controller
                    .refreshDashboard,
                child: SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(
                    parent:
                    BouncingScrollPhysics(),
                  ),
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    17,
                    18,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 430,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          DashboardHeader(
                            userName:
                            summary.userName,
                            onNotifications:
                            widget
                                .onNotifications,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          const BlockchainSecurityCard(),

                          const SizedBox(
                            height: 25,
                          ),

                          const _SectionTitle(
                            title:
                            'Quick Actions',
                          ),

                          const SizedBox(
                            height: 13,
                          ),

                          QuickActionsGrid(
                            onPolicies:
                            widget.onPolicies,
                            onFileClaim:
                            widget.onFileClaim,
                            onClaimStatus:
                            widget
                                .onClaimStatus,
                            onPayments:
                            widget.onPayments,
                          ),

                          const SizedBox(
                            height: 26,
                          ),

                          const _SectionTitle(
                            title: 'Overview',
                          ),

                          const SizedBox(
                            height: 13,
                          ),

                          DashboardOverviewCard(
                            activePolicies:
                            summary
                                .activePolicies,
                            activeClaims:
                            summary
                                .activeClaims,
                            totalClaims:
                            summary
                                .totalClaims,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),

      bottomNavigationBar:
      DashboardBottomNavigation(
        onHome: () {},
        onPolicies: widget.onPolicies,
        onAddClaim: widget.onFileClaim,
        onClaims: widget.onClaims,
        onProfile: widget.onProfile,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color:
              Color(0xFFFF8A9B),
              size: 42,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
              ),
            ),

            const SizedBox(height: 14),

            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}