import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/controllers/seller_dashboard_navigation_controller.dart';

class SellerBottomNavigation extends StatelessWidget {
  const SellerBottomNavigation({
    required this.selectedTab,
    required this.onSelected,
    super.key,
  });

  final SellerDashboardNavigationTab selectedTab;
  final ValueChanged<SellerDashboardNavigationTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.backgroundMiddle, AppColors.backgroundTop],
        ),
        border: Border(
          top: BorderSide(color: AppColors.white.withValues(alpha: 0.12)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          key: const Key('seller_bottom_navigation'),
          height: 68,
          child: Row(
            children: SellerDashboardNavigationTab.values
                .map(
                  (SellerDashboardNavigationTab tab) => _NavigationItem(
                    tab: tab,
                    selected: selectedTab == tab,
                    onPressed: () => onSelected(tab),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  final SellerDashboardNavigationTab tab;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String label = switch (tab) {
      SellerDashboardNavigationTab.home => 'Home',
      SellerDashboardNavigationTab.products => 'Products',
      SellerDashboardNavigationTab.applications => 'Applications',
      SellerDashboardNavigationTab.claims => 'Claims',
      SellerDashboardNavigationTab.profile => 'Profile',
    };
    final IconData icon = switch (tab) {
      SellerDashboardNavigationTab.home => Icons.home_rounded,
      SellerDashboardNavigationTab.products => Icons.inventory_2_outlined,
      SellerDashboardNavigationTab.applications => Icons.assignment_outlined,
      SellerDashboardNavigationTab.claims => Icons.fact_check_outlined,
      SellerDashboardNavigationTab.profile => Icons.person_outline_rounded,
    };
    final Color color = selected ? AppColors.blue : AppColors.textSecondary;

    return Expanded(
      child: Tooltip(
        message: label,
        child: Semantics(
          button: true,
          selected: selected,
          label: '$label seller navigation tab',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('seller_navigation_${tab.name}'),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, color: color, size: 21),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          color: color,
                          fontSize: 9.5,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      key: selected
                          ? Key('seller_navigation_${tab.name}_selected')
                          : null,
                      width: 18,
                      height: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selected ? AppColors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
