import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/seller_dashboard/application/controllers/seller_dashboard_navigation_controller.dart';

void main() {
  test('Home is selected by default', () {
    final SellerDashboardNavigationController controller =
        SellerDashboardNavigationController();

    expect(controller.selectedTab, SellerDashboardNavigationTab.home);
  });

  test('unavailable destinations do not replace Home', () {
    final SellerDashboardNavigationController controller =
        SellerDashboardNavigationController();

    for (final SellerDashboardNavigationTab tab
        in SellerDashboardNavigationTab.values.skip(1)) {
      expect(controller.selectTab(tab), isFalse);
      expect(controller.selectedTab, SellerDashboardNavigationTab.home);
    }
  });
}
