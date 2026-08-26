import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/application/controllers/payments_history_controller.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/payout_filter.dart';

void main() {
  test('loads payout history and filters it locally', () async {
    final MockClaimStatusRepository claimsRepository =
        MockClaimStatusRepository(delay: Duration.zero);
    final PaymentsHistoryController controller = PaymentsHistoryController(
      repository: MockClaimPayoutRepository(
        claimsRepository: claimsRepository,
        delay: Duration.zero,
      ),
    );

    await controller.initialize();
    expect(controller.loadStatus, PaymentsHistoryLoadStatus.success);
    expect(controller.payouts, hasLength(2));

    controller.changeFilter(PayoutFilter.processing);
    expect(controller.visiblePayouts, hasLength(1));
    expect(
      controller.visiblePayouts.single.status.matchesFilter(
        PayoutFilter.processing,
      ),
      isTrue,
    );

    controller.changeFilter(PayoutFilter.paid);
    expect(controller.visiblePayouts, hasLength(1));
    expect(controller.isInitialLoading, isFalse);
  });
}
