import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/application/controllers/payments_history_controller.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/presentation/pages/payments_history_page.dart';

void main() {
  testWidgets('renders and filters payment history and selects a payout', (
    WidgetTester tester,
  ) async {
    final MockClaimStatusRepository claimsRepository =
        MockClaimStatusRepository(delay: Duration.zero);
    ClaimPayout? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PaymentsHistoryPage(
          controller: PaymentsHistoryController(
            repository: MockClaimPayoutRepository(
              claimsRepository: claimsRepository,
              delay: Duration.zero,
            ),
          ),
          onBack: () {},
          onPayoutPressed: (ClaimPayout payout) {
            selected = payout;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payments'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('payout_history_payout-processing-001'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('payout_history_payout-paid-001')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('payout_filter_processing')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('payout_history_payout-paid-001')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(
        const ValueKey<String>('payout_history_payout-processing-001'),
      ),
    );
    expect(
      selected?.claimId,
      MockClaimStatusRepository.paymentProcessingClaimId,
    );
  });
}
