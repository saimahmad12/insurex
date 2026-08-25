import 'package:flutter/foundation.dart';

enum DashboardNavigationTab { home, policies }

class DashboardNavigationController extends ChangeNotifier {
  DashboardNavigationController({
    DashboardNavigationTab initialTab = DashboardNavigationTab.home,
  }) : _selectedTab = initialTab;

  DashboardNavigationTab _selectedTab;

  DashboardNavigationTab get selectedTab => _selectedTab;

  int get selectedIndex => _selectedTab.index;

  void showHome() {
    _select(DashboardNavigationTab.home);
  }

  void showPolicies() {
    _select(DashboardNavigationTab.policies);
  }

  void _select(DashboardNavigationTab tab) {
    if (_selectedTab == tab) {
      return;
    }

    _selectedTab = tab;
    notifyListeners();
  }
}
