import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/my_claims_controller.dart';
import '../../domain/entities/claim_filter.dart';
import '../../domain/entities/insurance_claim.dart';
import '../widgets/claim_filter_tabs.dart';
import '../widgets/claim_history_card.dart';
import '../widgets/claim_search_field.dart';
import '../widgets/claims_empty_state.dart';
import '../widgets/claims_summary.dart';

class MyClaimsPage extends StatefulWidget {
  const MyClaimsPage({
    required this.controller,
    required this.onBack,
    required this.onClaimPressed,
    required this.onFileClaim,
    super.key,
  });

  final MyClaimsController controller;
  final VoidCallback onBack;
  final ValueChanged<InsuranceClaim> onClaimPressed;
  final VoidCallback onFileClaim;

  @override
  State<MyClaimsPage> createState() => _MyClaimsPageState();
}

class _MyClaimsPageState extends State<MyClaimsPage> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    widget.controller.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (BuildContext context, Widget? child) {
                        return _MyClaimsHeader(
                          onBack: widget.onBack,
                          onRefresh: widget.controller.refresh,
                          isRefreshing: widget.controller.isRefreshing,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (BuildContext context, Widget? child) {
                    if (widget.controller.isInitialLoading) {
                      return const Center(
                        key: Key('my_claims_initial_loading'),
                        child: CircularProgressIndicator(color: AppColors.blue),
                      );
                    }

                    return RefreshIndicator(
                      key: const Key('my_claims_refresh_indicator'),
                      color: AppColors.blue,
                      onRefresh: widget.controller.refresh,
                      child: ListView(
                        key: const PageStorageKey<String>(
                          'my_claims_scroll_view',
                        ),
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                        children: <Widget>[
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _buildContent(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (widget.controller.loadStatus == MyClaimsLoadStatus.failure &&
        widget.controller.claims.isEmpty) {
      return <Widget>[
        const SizedBox(height: 72),
        ClaimsEmptyState(
          title: 'Unable to load claims',
          message:
              widget.controller.errorMessage ?? 'Please try again in a moment.',
          actionLabel: 'Try Again',
          onAction: widget.controller.retry,
        ),
      ];
    }

    final List<InsuranceClaim> visibleClaims = widget.controller.visibleClaims;
    return <Widget>[
      ClaimsSummary(
        total: widget.controller.totalClaimsCount,
        active: widget.controller.activeClaimsCount,
        approved: widget.controller.approvedClaimsCount,
        settled: widget.controller.settledClaimsCount,
      ),
      const SizedBox(height: 16),
      ClaimSearchField(
        controller: _searchController,
        query: widget.controller.searchQuery,
        onChanged: widget.controller.updateSearchQuery,
        onClear: widget.controller.clearSearch,
      ),
      const SizedBox(height: 14),
      ClaimFilterTabs(
        selectedFilter: widget.controller.selectedFilter,
        onFilterChanged: widget.controller.changeFilter,
      ),
      if (widget.controller.refreshErrorMessage != null) ...<Widget>[
        const SizedBox(height: 14),
        _RefreshError(
          message: widget.controller.refreshErrorMessage!,
          onRetry: widget.controller.refresh,
        ),
      ],
      const SizedBox(height: 18),
      if (widget.controller.claims.isEmpty)
        ClaimsEmptyState(
          title: 'No claims yet',
          message: 'You haven’t submitted an insurance claim.',
          actionLabel: 'File a Claim',
          onAction: widget.onFileClaim,
        )
      else if (visibleClaims.isEmpty)
        _filteredEmptyState()
      else
        ...visibleClaims.map((InsuranceClaim claim) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ClaimHistoryCard(
              claim: claim,
              onPressed: () {
                widget.onClaimPressed(claim);
              },
            ),
          );
        }),
    ];
  }

  Widget _filteredEmptyState() {
    if (widget.controller.searchQuery.trim().isNotEmpty) {
      return const ClaimsEmptyState(
        title: 'No search results',
        message: 'Try a different claim ID, policy, or incident type.',
      );
    }

    final ClaimFilter filter = widget.controller.selectedFilter;
    final String category = switch (filter) {
      ClaimFilter.all => 'claims',
      ClaimFilter.active => 'active claims',
      ClaimFilter.approved => 'approved claims',
      ClaimFilter.rejected => 'rejected claims',
      ClaimFilter.settled => 'settled claims',
    };
    return ClaimsEmptyState(
      title: 'No $category',
      message: 'You don’t have any claims in this category.',
      actionLabel: filter == ClaimFilter.active ? 'File a Claim' : null,
      onAction: filter == ClaimFilter.active ? widget.onFileClaim : null,
    );
  }
}

class _MyClaimsHeader extends StatelessWidget {
  const _MyClaimsHeader({
    required this.onBack,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _HeaderButton(
          key: const Key('my_claims_back_button'),
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onBack,
        ),
        const Expanded(
          child: Text(
            'My Claims',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _HeaderButton(
          key: const Key('my_claims_refresh_button'),
          icon: Icons.refresh_rounded,
          onPressed: isRefreshing ? null : onRefresh,
          isLoading: isRefreshing,
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(13),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.blue,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: AppColors.white, size: 20),
            ),
    );
  }
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('my_claims_refresh_error'),
      padding: const EdgeInsets.fromLTRB(14, 10, 7, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF718A).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF718A).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFFB3BE),
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
