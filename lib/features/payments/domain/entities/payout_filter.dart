import 'claim_payout.dart';

enum PayoutFilter { all, processing, paid, failed }

extension PayoutFilterMatching on ClaimPayoutStatus {
  bool matchesFilter(PayoutFilter filter) {
    return switch (filter) {
      PayoutFilter.all => true,
      PayoutFilter.processing => this == ClaimPayoutStatus.processing,
      PayoutFilter.paid => this == ClaimPayoutStatus.paid,
      PayoutFilter.failed => this == ClaimPayoutStatus.failed,
    };
  }
}
