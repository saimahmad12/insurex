enum SellerDashboardAccountStatus { approved, notApproved }

class SellerDashboardAccount {
  const SellerDashboardAccount({
    required this.companyName,
    required this.businessEmail,
    required this.status,
  });

  final String companyName;
  final String businessEmail;
  final SellerDashboardAccountStatus status;

  bool get isApproved => status == SellerDashboardAccountStatus.approved;

  String get initials {
    final List<String> words = companyName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return 'IX';
    }
    return words.take(2).map((String word) => word[0].toUpperCase()).join();
  }
}

class SellerDashboardSummary {
  const SellerDashboardSummary({
    required this.activeProducts,
    required this.pendingApplications,
    required this.activePolicies,
    required this.openClaims,
    required this.premiumCollected,
    required this.pendingSettlements,
  });

  final int activeProducts;
  final int pendingApplications;
  final int activePolicies;
  final int openClaims;
  final double premiumCollected;
  final double pendingSettlements;

  bool get isEmpty =>
      activeProducts == 0 &&
      pendingApplications == 0 &&
      activePolicies == 0 &&
      openClaims == 0 &&
      premiumCollected == 0 &&
      pendingSettlements == 0;
}

enum SellerApplicationStatus { awaitingReview, documentsRequired, approved }

class SellerRecentApplication {
  const SellerRecentApplication({
    required this.reference,
    required this.applicantName,
    required this.productName,
    required this.submittedAt,
    required this.status,
  });

  final String reference;
  final String applicantName;
  final String productName;
  final DateTime submittedAt;
  final SellerApplicationStatus status;
}

enum SellerClaimStatus { underReview, evidenceRequired, settlementReady }

class SellerRecentClaim {
  const SellerRecentClaim({
    required this.reference,
    required this.policyHolderName,
    required this.category,
    required this.claimedAmount,
    required this.submittedAt,
    required this.status,
  });

  final String reference;
  final String policyHolderName;
  final String category;
  final double claimedAmount;
  final DateTime submittedAt;
  final SellerClaimStatus status;
}

class SellerSalesPoint {
  const SellerSalesPoint({required this.label, required this.premium});

  final String label;
  final double premium;
}

class SellerPolicyCategoryPerformance {
  const SellerPolicyCategoryPerformance({
    required this.category,
    required this.activePolicies,
    required this.premiumCollected,
    required this.share,
  });

  final String category;
  final int activePolicies;
  final double premiumCollected;
  final double share;
}

class SellerDashboard {
  SellerDashboard({
    required this.summary,
    required List<SellerRecentApplication> recentApplications,
    required List<SellerRecentClaim> recentClaims,
    required List<SellerSalesPoint> salesOverview,
    required List<SellerPolicyCategoryPerformance> categoryPerformance,
    required this.generatedAt,
  }) : recentApplications = List<SellerRecentApplication>.unmodifiable(
         recentApplications,
       ),
       recentClaims = List<SellerRecentClaim>.unmodifiable(recentClaims),
       salesOverview = List<SellerSalesPoint>.unmodifiable(salesOverview),
       categoryPerformance = List<SellerPolicyCategoryPerformance>.unmodifiable(
         categoryPerformance,
       );

  final SellerDashboardSummary summary;
  final List<SellerRecentApplication> recentApplications;
  final List<SellerRecentClaim> recentClaims;
  final List<SellerSalesPoint> salesOverview;
  final List<SellerPolicyCategoryPerformance> categoryPerformance;
  final DateTime generatedAt;

  bool get isEmpty =>
      summary.isEmpty &&
      recentApplications.isEmpty &&
      recentClaims.isEmpty &&
      salesOverview.isEmpty &&
      categoryPerformance.isEmpty;
}
