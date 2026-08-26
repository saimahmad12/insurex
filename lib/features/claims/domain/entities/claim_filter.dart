import 'claim_submission_result.dart';

enum ClaimFilter { all, active, approved, rejected, settled }

extension ClaimStatusClassification on ClaimStatus {
  bool get isActiveClaim {
    return switch (this) {
      ClaimStatus.submitted ||
      ClaimStatus.aiAnalysisPending ||
      ClaimStatus.aiAnalysisCompleted ||
      ClaimStatus.underReview ||
      ClaimStatus.additionalEvidenceRequired ||
      ClaimStatus.paymentProcessing => true,
      ClaimStatus.approved ||
      ClaimStatus.rejected ||
      ClaimStatus.settled => false,
    };
  }

  bool matchesFilter(ClaimFilter filter) {
    return switch (filter) {
      ClaimFilter.all => true,
      ClaimFilter.active => isActiveClaim,
      ClaimFilter.approved => this == ClaimStatus.approved,
      ClaimFilter.rejected => this == ClaimStatus.rejected,
      ClaimFilter.settled => this == ClaimStatus.settled,
    };
  }
}
