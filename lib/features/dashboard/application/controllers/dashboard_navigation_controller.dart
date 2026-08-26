import 'package:flutter/foundation.dart';

enum DashboardNavigationTab { home, policies, claims }

class DashboardNavigationController extends ChangeNotifier {
  DashboardNavigationController({
    DashboardNavigationTab initialTab = DashboardNavigationTab.home,
  }) : _selectedTab = initialTab;

  DashboardNavigationTab _selectedTab;

  DashboardNavigationTab get selectedTab => _selectedTab;

  int get stackIndex => _selectedTab.index;

  int get selectedIndex => switch (_selectedTab) {
    DashboardNavigationTab.home => 0,
    DashboardNavigationTab.policies => 1,
    DashboardNavigationTab.claims => 3,
  };

  void showHome() {
    _select(DashboardNavigationTab.home);
  }

  void showPolicies() {
    _select(DashboardNavigationTab.policies);
  }

  void showClaims() {
    _select(DashboardNavigationTab.claims);
  }

  void _select(DashboardNavigationTab tab) {
    if (_selectedTab == tab) {
      return;
    }

    _selectedTab = tab;
    notifyListeners();
  }
}
