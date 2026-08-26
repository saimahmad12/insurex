import 'package:flutter/material.dart';

import '../../../claims/application/controllers/my_claims_controller.dart';
import '../../../claims/domain/entities/insurance_claim.dart';
import '../../../claims/presentation/pages/my_claims_page.dart';
import '../../../policies/application/controllers/policies_controller.dart';
import '../../../policies/domain/entities/insurance_policy.dart';
import '../../../policies/presentation/pages/my_policies_page.dart';
import '../../application/controllers/dashboard_controller.dart';
import '../../application/controllers/dashboard_navigation_controller.dart';
import '../widgets/dashboard_bottom_navigation.dart';
import 'dashboard_page.dart';

class DashboardNavigationShell extends StatefulWidget {
  const DashboardNavigationShell({
    required this.navigationController,
    required this.dashboardController,
    required this.policiesController,
    required this.myClaimsController,
    required this.onFileClaim,
    required this.onClaimStatus,
    required this.onClaimPressed,
    required this.onPayments,
    required this.onNotifications,
    required this.onProfile,
    required this.onPolicySearch,
    required this.onPolicyPressed,
    required this.onBuyPolicy,
    super.key,
  });

  final DashboardNavigationController navigationController;
  final DashboardController dashboardController;
  final PoliciesController policiesController;
  final MyClaimsController myClaimsController;
  final VoidCallback onFileClaim;
  final VoidCallback onClaimStatus;
  final ValueChanged<InsuranceClaim> onClaimPressed;
  final VoidCallback onPayments;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onPolicySearch;
  final ValueChanged<InsurancePolicy> onPolicyPressed;
  final VoidCallback onBuyPolicy;

  @override
  State<DashboardNavigationShell> createState() =>
      _DashboardNavigationShellState();
}

class _DashboardNavigationShellState extends State<DashboardNavigationShell> {
  @override
  void dispose() {
    widget.navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.navigationController,
      builder: (BuildContext context, Widget? child) {
        final bool isHome =
            widget.navigationController.selectedTab ==
            DashboardNavigationTab.home;

        return PopScope<Object?>(
          canPop: isHome,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              widget.navigationController.showHome();
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: widget.navigationController.stackIndex,
              children: <Widget>[
                DashboardPage(
                  controller: widget.dashboardController,
                  onPolicies: widget.navigationController.showPolicies,
                  onFileClaim: widget.onFileClaim,
                  onClaimStatus: widget.onClaimStatus,
                  onPayments: widget.onPayments,
                  onNotifications: widget.onNotifications,
                ),
                MyPoliciesPage(
                  controller: widget.policiesController,
                  onBack: widget.navigationController.showHome,
                  onPolicyPressed: widget.onPolicyPressed,
                  onBuyPolicy: widget.onBuyPolicy,
                  onSearch: widget.onPolicySearch,
                ),
                MyClaimsPage(
                  controller: widget.myClaimsController,
                  onBack: widget.navigationController.showHome,
                  onClaimPressed: widget.onClaimPressed,
                  onFileClaim: widget.onFileClaim,
                ),
              ],
            ),
            bottomNavigationBar: DashboardBottomNavigation(
              selectedIndex: widget.navigationController.selectedIndex,
              onHome: widget.navigationController.showHome,
              onPolicies: widget.navigationController.showPolicies,
              onAddClaim: widget.onFileClaim,
              onClaims: widget.navigationController.showClaims,
              onProfile: widget.onProfile,
            ),
          ),
        );
      },
    );
  }
}
