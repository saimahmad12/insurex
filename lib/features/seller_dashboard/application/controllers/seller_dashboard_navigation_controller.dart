import 'package:flutter/foundation.dart';

enum SellerDashboardNavigationTab {
  home,
  products,
  applications,
  claims,
  profile,
}

class SellerDashboardNavigationController extends ChangeNotifier {
  SellerDashboardNavigationController({
    SellerDashboardNavigationTab initialTab = SellerDashboardNavigationTab.home,
    Set<SellerDashboardNavigationTab> availableTabs =
        const <SellerDashboardNavigationTab>{SellerDashboardNavigationTab.home},
  }) : assert(availableTabs.contains(initialTab)),
       _selectedTab = initialTab,
       _availableTabs = Set<SellerDashboardNavigationTab>.unmodifiable(
         availableTabs,
       );

  SellerDashboardNavigationTab _selectedTab;
  final Set<SellerDashboardNavigationTab> _availableTabs;

  SellerDashboardNavigationTab get selectedTab => _selectedTab;

  bool selectTab(SellerDashboardNavigationTab tab) {
    if (!_availableTabs.contains(tab)) {
      return false;
    }
    if (_selectedTab == tab) {
      return true;
    }

    _selectedTab = tab;
    notifyListeners();
    return true;
  }
}
