import 'package:flutter/material.dart';

import '../../application/controllers/seller_dashboard_navigation_controller.dart';
import '../widgets/seller_bottom_navigation.dart';

class SellerDashboardNavigationShell extends StatelessWidget {
  const SellerDashboardNavigationShell({
    required this.navigationController,
    required this.home,
    required this.onUnavailableDestination,
    super.key,
  });

  final SellerDashboardNavigationController navigationController;
  final Widget home;
  final VoidCallback onUnavailableDestination;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: home,
        bottomNavigationBar: AnimatedBuilder(
          animation: navigationController,
          builder: (BuildContext context, Widget? child) {
            return SellerBottomNavigation(
              selectedTab: navigationController.selectedTab,
              onSelected: (SellerDashboardNavigationTab tab) {
                final bool selected = navigationController.selectTab(tab);
                if (!selected) {
                  onUnavailableDestination();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
