import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/seller_dashboard.dart';

String formatSellerNumber(num value) {
  final String digits = value.round().abs().toString();
  final StringBuffer result = StringBuffer();
  for (int index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      result.write(',');
    }
    result.write(digits[index]);
  }
  return value < 0 ? '-$result' : result.toString();
}

String formatSellerCurrency(num value) => 'PKR ${formatSellerNumber(value)}';

String _formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return 'PKR ${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return 'PKR ${(value / 1000).toStringAsFixed(0)}K';
  }
  return formatSellerCurrency(value);
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class SellerRecentApplicationsSection extends StatelessWidget {
  const SellerRecentApplicationsSection({
    required this.applications,
    super.key,
  });

  final List<SellerRecentApplication> applications;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Applications',
      child: Column(
        children: <Widget>[
          for (int index = 0; index < applications.length; index++) ...<Widget>[
            _ApplicationRow(application: applications[index]),
            if (index != applications.length - 1) const _GlassDivider(),
          ],
        ],
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.application});

  final SellerRecentApplication application;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  application.applicantName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: switch (application.status) {
                  SellerApplicationStatus.awaitingReview => 'Awaiting Review',
                  SellerApplicationStatus.documentsRequired =>
                    'Documents Required',
                  SellerApplicationStatus.approved => 'Approved',
                },
                accent: switch (application.status) {
                  SellerApplicationStatus.awaitingReview => AppColors.blue,
                  SellerApplicationStatus.documentsRequired => AppColors.pink,
                  SellerApplicationStatus.approved => AppColors.violet,
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            application.productName,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.78),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${application.reference}  •  ${_formatDate(application.submittedAt)}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SellerRecentClaimsSection extends StatelessWidget {
  const SellerRecentClaimsSection({required this.claims, super.key});

  final List<SellerRecentClaim> claims;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Claims',
      child: Column(
        children: <Widget>[
          for (int index = 0; index < claims.length; index++) ...<Widget>[
            _ClaimRow(claim: claims[index]),
            if (index != claims.length - 1) const _GlassDivider(),
          ],
        ],
      ),
    );
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({required this.claim});

  final SellerRecentClaim claim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  claim.policyHolderName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: switch (claim.status) {
                  SellerClaimStatus.underReview => 'Under Review',
                  SellerClaimStatus.evidenceRequired => 'Evidence Required',
                  SellerClaimStatus.settlementReady => 'Settlement Ready',
                },
                accent: switch (claim.status) {
                  SellerClaimStatus.underReview => AppColors.blue,
                  SellerClaimStatus.evidenceRequired => AppColors.pink,
                  SellerClaimStatus.settlementReady => AppColors.violet,
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${claim.category}  •  ${formatSellerCurrency(claim.claimedAmount)}',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.78),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${claim.reference}  •  ${_formatDate(claim.submittedAt)}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SellerSalesOverviewCard extends StatelessWidget {
  const SellerSalesOverviewCard({required this.points, super.key});

  final List<SellerSalesPoint> points;

  @override
  Widget build(BuildContext context) {
    final double maximum = points.fold<double>(
      1,
      (double current, SellerSalesPoint point) =>
          point.premium > current ? point.premium : current,
    );
    return _SectionCard(
      title: 'Sales Overview',
      child: Padding(
        padding: const EdgeInsets.only(top: 17, bottom: 5),
        child: SizedBox(
          height: 165,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: points
                .map(
                  (SellerSalesPoint point) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatCompactCurrency(point.premium),
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: point.premium / maximum,
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: <Color>[
                                      AppColors.violet,
                                      AppColors.blue,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            point.label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class SellerPolicyCategoryPerformanceCard extends StatelessWidget {
  const SellerPolicyCategoryPerformanceCard({
    required this.categories,
    super.key,
  });

  final List<SellerPolicyCategoryPerformance> categories;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Policy Category Performance',
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Column(
          children: categories
              .map(
                (SellerPolicyCategoryPerformance category) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              category.category,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${formatSellerNumber(category.activePolicies)} policies',
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 10.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCompactCurrency(category.premiumCollected),
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: category.share.clamp(0, 1),
                          minHeight: 6,
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.08,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 116),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: accent,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _GlassDivider extends StatelessWidget {
  const _GlassDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.white.withValues(alpha: 0.08));
  }
}
