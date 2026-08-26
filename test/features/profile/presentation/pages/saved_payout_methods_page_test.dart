import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'package:insurancex/features/payments/domain/entities/claim_payout.dart';
import 'package:insurancex/features/payments/domain/entities/payout_method.dart';
import 'package:insurancex/features/profile/application/controllers/saved_payout_methods_controller.dart';
import 'package:insurancex/features/profile/presentation/pages/saved_payout_methods_page.dart';

void main() {
  testWidgets('shows masked saved methods, status, and default indicator', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, repository: _repository());
    await tester.pumpAndSettle();

    expect(find.text('**** **** **** 4821'), findsOneWidget);
    expect(find.text('03** *** 4821'), findsOneWidget);
    expect(find.text('03** *** 7314'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Verified'), findsNWidgets(3));
    expect(find.textContaining('03001234567'), findsNothing);
  });

  testWidgets('shows empty state and reuses the existing add-method form', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      repository: _repository(initialMethods: const <PayoutMethod>[]),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved_payout_methods_empty')), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('payout_method_type_easypaisa')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('payout_method_form_easypaisa')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('payout_account_holder_field')),
      'Ayesha Khan',
    );
    await tester.enterText(
      find.byKey(const Key('payout_destination_field')),
      '03001234567',
    );
    final Finder verify = find.byKey(const Key('verify_payout_method_button'));
    await tester.ensureVisible(verify);
    await tester.pumpAndSettle();
    await tester.tap(verify);
    await tester.pumpAndSettle();

    expect(find.text('03** *** 4567'), findsOneWidget);
    expect(find.text('03001234567'), findsNothing);
    expect(find.text('Default'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required MockClaimPayoutRepository repository,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: SavedPayoutMethodsPage(
        controller: SavedPayoutMethodsController(repository: repository),
        onBack: () {},
      ),
    ),
  );
}

MockClaimPayoutRepository _repository({List<PayoutMethod>? initialMethods}) {
  return MockClaimPayoutRepository(
    claimsRepository: MockClaimStatusRepository(delay: Duration.zero),
    delay: Duration.zero,
    initialMethods: initialMethods,
    initialPayouts: const <ClaimPayout>[],
  );
}
