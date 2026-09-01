import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/presentation/widgets/profile_page_header.dart';
import '../../application/controllers/insurance_product_controller.dart';
import '../../domain/entities/insurance_product.dart';
import '../widgets/insurance_product_card.dart';

class InsuranceProductDetailsPage extends StatefulWidget {
  const InsuranceProductDetailsPage({
    required this.controller,
    required this.onBack,
    required this.onBuyNow,
    required this.onCompare,
    required this.onContactSupport,
    super.key,
  });

  final InsuranceProductController controller;
  final VoidCallback onBack;
  final ValueChanged<InsuranceProduct> onBuyNow;
  final ValueChanged<InsuranceProduct> onCompare;
  final VoidCallback onContactSupport;

  @override
  State<InsuranceProductDetailsPage> createState() =>
      _InsuranceProductDetailsPageState();
}

class _InsuranceProductDetailsPageState
    extends State<InsuranceProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
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
              if (widget.controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final InsuranceProduct? product = widget.controller.product;
              if (product == null) {
                return _Unavailable(
                  message:
                      widget.controller.errorMessage ??
                      'This insurance product is unavailable.',
                  onBack: widget.onBack,
                  onRetry: widget.controller.retry,
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                children: <Widget>[
                  ProfilePageHeader(
                    title: 'Product Details',
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 22),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF49E6A4),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${product.providerName} • Verified provider',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _Metric(
                                label: 'Starting premium',
                                value: marketplaceMoney(
                                  product.startingPremium,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _Metric(
                                label: 'Coverage up to',
                                value: marketplaceMoney(
                                  product.maximumCoverage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailsSection(
                    title: 'Coverage & Benefits',
                    items: <String>[
                      ...product.keyBenefits,
                      ...product.coveredEvents,
                    ],
                  ),
                  _DetailsSection(
                    title: 'Exclusions',
                    items: product.exclusions,
                  ),
                  _DetailsSection(
                    title: 'Eligibility',
                    items: product.eligibilityRequirements,
                  ),
                  _InformationSection(
                    rows: <String, String>{
                      'Duration': product.availableDurationsMonths
                          .map((int value) => '$value months')
                          .join(', '),
                      'Deductible': product.availableDeductibles
                          .map(marketplaceMoney)
                          .join(', '),
                      'Waiting period': product.waitingPeriod,
                      'Claim limits': product.claimLimits,
                      'Cancellation': product.cancellationTerms,
                      'Required information': product.requiredInformation.join(
                        ', ',
                      ),
                      'Terms': product.termsSummary,
                    },
                  ),
                  const SizedBox(height: 8),
                  GlassActionButton(
                    key: const Key('product_buy_now_button'),
                    label: 'Buy Now',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: product.isAvailable
                        ? () => widget.onBuyNow(product)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => widget.onCompare(product),
                          icon: const Icon(Icons.compare_arrows_rounded),
                          label: const Text('Compare'),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: widget.controller.toggleFavourite,
                          icon: Icon(
                            widget.controller.isFavourite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                          label: Text(
                            widget.controller.isFavourite ? 'Saved' : 'Save',
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: widget.onContactSupport,
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text('Contact Support'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.title, required this.items});
  final String title;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.circle, color: AppColors.blue, size: 7),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _InformationSection extends StatelessWidget {
  const _InformationSection({required this.rows});
  final Map<String, String> rows;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          for (final MapEntry<String, String> row in rows.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 125,
                    child: Text(
                      row.key,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          ProfilePageHeader(title: 'Product Details', onBack: onBack),
          const Spacer(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
          const Spacer(),
        ],
      ),
    ),
  );
}
