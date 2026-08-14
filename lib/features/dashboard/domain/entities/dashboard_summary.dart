class DashboardSummary {
  const DashboardSummary({
    required this.userName,
    required this.activePolicies,
    required this.activeClaims,
    required this.totalClaims,
  });

  final String userName;
  final int activePolicies;
  final int activeClaims;
  final int totalClaims;
}