import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../profile/presentation/widgets/profile_page_header.dart';
import '../../application/controllers/insurance_marketplace_controller.dart';
import '../../domain/entities/insurance_product.dart';
import '../widgets/insurance_product_card.dart';

class InsuranceMarketplacePage extends StatefulWidget {
  const InsuranceMarketplacePage({
    required this.controller,
    required this.onBack,
    required this.onProductPressed,
    required this.onCompare,
    super.key,
  });

  final InsuranceMarketplaceController controller;
  final VoidCallback onBack;
  final ValueChanged<InsuranceProduct> onProductPressed;
  final ValueChanged<List<InsuranceProduct>> onCompare;

  @override
  State<InsuranceMarketplacePage> createState() =>
      _InsuranceMarketplacePageState();
}

class _InsuranceMarketplacePageState extends State<InsuranceMarketplacePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return RefreshIndicator(
                onRefresh: widget.controller.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  children: <Widget>[
                    ProfilePageHeader(
                      title: 'Insurance Marketplace',
                      onBack: widget.onBack,
                      onRefresh: widget.controller.refresh,
                      isRefreshing: widget.controller.isRefreshing,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      key: const Key('marketplace_search_field'),
                      controller: _searchController,
                      onSubmitted: widget.controller.updateSearch,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: 'Search products or providers',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          tooltip: 'Search',
                          onPressed: () => widget.controller.updateSearch(
                            _searchController.text,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Filters(controller: widget.controller),
                    const SizedBox(height: 18),
                    if (widget.controller.comparisonIds.isNotEmpty) ...<Widget>[
                      GlassActionButton(
                        label:
                            'Compare (${widget.controller.comparisonIds.length})',
                        icon: Icons.compare_arrows_rounded,
                        variant: GlassButtonVariant.secondary,
                        onPressed:
                            widget.controller.comparisonProducts.length < 2
                            ? null
                            : () => widget.onCompare(
                                widget.controller.comparisonProducts,
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (widget.controller.errorMessage != null &&
                        widget.controller.products.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          widget.controller.errorMessage!,
                          style: const TextStyle(color: Color(0xFFFFC857)),
                        ),
                      ),
                    _content(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (widget.controller.isInitialLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.controller.loadStatus == MarketplaceLoadStatus.failure) {
      return _MarketplaceMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Products unavailable',
        message: widget.controller.errorMessage ?? 'Please try again.',
        action: 'Try Again',
        onPressed: widget.controller.retry,
      );
    }
    if (widget.controller.products.isEmpty) {
      return const _MarketplaceMessage(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Try another search or filter.',
      );
    }
    return Column(
      children: <Widget>[
        for (final InsuranceProduct product in widget.controller.products)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InsuranceProductCard(
              product: product,
              isFavourite: widget.controller.favouriteIds.contains(product.id),
              isCompared: widget.controller.comparisonIds.contains(product.id),
              onPressed: () => widget.onProductPressed(product),
              onFavourite: () => widget.controller.toggleFavourite(product.id),
              onCompare: () => widget.controller.toggleComparison(product.id),
            ),
          ),
        if (widget.controller.hasMore)
          TextButton(
            onPressed:
                widget.controller.paginationStatus ==
                    MarketplacePaginationStatus.loading
                ? null
                : widget.controller.loadMore,
            child:
                widget.controller.paginationStatus ==
                    MarketplacePaginationStatus.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load More'),
          ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller});
  final InsuranceMarketplaceController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DropdownButton<String>(
        key: const Key('marketplace_provider_filter'),
        value: controller.query.providerName ?? '',
        hint: const Text('Provider'),
        dropdownColor: AppColors.backgroundMiddle,
        items: <DropdownMenuItem<String>>[
          const DropdownMenuItem<String>(
            value: '',
            child: Text('Any Provider'),
          ),
          ...controller.availableProviders.map(
            (String provider) => DropdownMenuItem<String>(
              value: provider,
              child: Text(provider),
            ),
          ),
        ],
        onChanged: (String? value) =>
            controller.setProvider(value?.isEmpty == true ? null : value),
      ),
    );
  }
}

class _MarketplaceMessage extends StatelessWidget {
  const _MarketplaceMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onPressed,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 72),
    child: Column(
      children: <Widget>[
        Icon(icon, color: AppColors.textSecondary, size: 42),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        if (action != null)
          TextButton(onPressed: onPressed, child: Text(action!)),
      ],
    ),
  );
}
