import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/application/controllers/claim_payout_controller.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/presentation/pages/claim_payout_flow_page.dart';

void main() {
  testWidgets('completes the saved-method payout flow and shows a receipt', (
    WidgetTester tester,
  ) async {
    final MockClaimStatusRepository claimsRepository =
        MockClaimStatusRepository(delay: Duration.zero);
    final ClaimPayoutController controller = ClaimPayoutController(
      claimId: MockClaimStatusRepository.approvedClaimId,
      claimsRepository: claimsRepository,
      payoutRepository: MockClaimPayoutRepository(
        claimsRepository: claimsRepository,
        delay: Duration.zero,
        initialPayouts: const <ClaimPayout>[],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: ClaimPayoutFlowPage(
          controller: controller,
          onClose: () {},
          onReturnToClaimStatus: () {},
          onReturnToMyClaims: () {},
          onPlaceholderAction: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Receive Payment'), findsOneWidget);
    expect(find.text('Rs. 105,000'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('saved_payout_method_pm-bank-001')),
    );
    await tester.pump();
    final Finder continueButton = find.byKey(
      const Key('continue_saved_method_button'),
    );
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Review and Confirm'), findsOneWidget);
    await tester.tap(find.byKey(const Key('payout_consent_checkbox')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm_payout_button')));
    await tester.pumpAndSettle();

    expect(find.text('Payment Processing'), findsOneWidget);
    await tester.tap(find.byKey(const Key('check_payout_status_button')));
    await tester.pumpAndSettle();
    expect(find.text('Payment Successful'), findsOneWidget);

    await tester.tap(find.byKey(const Key('view_payout_receipt_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('payout_receipt_card')), findsOneWidget);
    expect(find.text('PAY-2026-0011'), findsOneWidget);
  });
}
