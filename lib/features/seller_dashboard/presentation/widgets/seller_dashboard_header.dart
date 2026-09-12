import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/seller_dashboard.dart';

class SellerDashboardHeader extends StatelessWidget {
  const SellerDashboardHeader({
    required this.account,
    required this.onNotifications,
    required this.onRefresh,
    required this.isRefreshing,
    super.key,
  });

  final SellerDashboardAccount account;
  final VoidCallback onNotifications;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: _CompanyIdentity(account: account)),
        const SizedBox(width: 8),
        _HeaderAction(
          key: const Key('seller_dashboard_notifications'),
          tooltip: 'Seller notifications',
          icon: Icons.notifications_none_rounded,
          onPressed: onNotifications,
        ),
        const SizedBox(width: 4),
        _HeaderAction(
          key: const Key('seller_dashboard_refresh'),
          tooltip: isRefreshing ? 'Refreshing dashboard' : 'Refresh dashboard',
          icon: Icons.refresh_rounded,
          onPressed: isRefreshing ? null : onRefresh,
        ),
      ],
    );
  }
}

class _CompanyIdentity extends StatelessWidget {
  const _CompanyIdentity({required this.account});

  final SellerDashboardAccount account;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Semantics(
          label: '${account.companyName} logo placeholder',
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.violet, AppColors.blue],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.32),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Text(
              account.initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                account.companyName,
                key: const Key('seller_dashboard_company_name'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    label: 'Seller account verified and approved',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.blue.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.42),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.blue,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Approved Seller',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.white.withValues(alpha: 0.06),
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      icon: Icon(icon, color: AppColors.white, size: 21),
    );
  }
}
