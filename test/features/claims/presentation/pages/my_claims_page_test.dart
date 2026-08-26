import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/application/controllers/my_claims_controller.dart';
import 'package:insurancex/features/claims/data/repositories/mock_claim_status_repository.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_status_repository.dart';
import 'package:insurancex/features/claims/presentation/pages/my_claims_page.dart';

void main() {
  testWidgets('renders claim totals, search, filters, and claim history', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      repository: MockClaimStatusRepository(delay: Duration.zero),
    );
    await _pumpFrames(tester);

    expect(find.text('My Claims'), findsOneWidget);
    expect(find.byKey(const Key('claims_summary')), findsOneWidget);
    expect(find.byKey(const Key('claim_search_field')), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'claim_card_${MockClaimStatusRepository.submittedClaimId}',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Analysis Pending'), findsWidgets);
    expect(find.text('Low Risk'), findsWidgets);
  });

  testWidgets('search and filters update locally without reloading', (
    WidgetTester tester,
  ) async {
    final List<InsuranceClaim> claims = await MockClaimStatusRepository(
      delay: Duration.zero,
    ).getClaims();
    final _FakeRepository repository = _FakeRepository(() async => claims);
    await _pumpPage(tester, repository: repository);
    await _pumpFrames(tester);

    await tester.enterText(
      find.byKey(const Key('claim_search_field')),
      'Health Insurance',
    );
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey<String>(
          'claim_card_${MockClaimStatusRepository.aiPendingClaimId}',
        ),
      ),
      findsOneWidget,
    );
    expect(repository.getClaimsCalls, 1);

    await tester.tap(find.byKey(const Key('clear_claim_search')));
    await tester.tap(
      find.byKey(const ValueKey<String>('claim_filter_rejected')),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(
        const ValueKey<String>(
          'claim_card_${MockClaimStatusRepository.rejectedClaimId}',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Rejected'), findsWidgets);
    expect(repository.getClaimsCalls, 1);
  });

  testWidgets('shows empty, filtered-empty, and no-search-results states', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      repository: _FakeRepository(() async => <InsuranceClaim>[]),
    );
    await _pumpFrames(tester);
    expect(find.text('No claims yet'), findsOneWidget);
    expect(find.text('File a Claim'), findsOneWidget);

    final List<InsuranceClaim> claims = await MockClaimStatusRepository(
      delay: Duration.zero,
    ).getClaims();
    await _pumpPage(
      tester,
      repository: _FakeRepository(
        () async => claims
            .where(
              (InsuranceClaim claim) =>
                  claim.id == MockClaimStatusRepository.approvedClaimId,
            )
            .toList(),
      ),
    );
    await _pumpFrames(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('claim_filter_rejected')),
    );
    await _pumpFrames(tester);
    expect(find.text('No rejected claims'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('claim_search_field')),
      'not-a-claim',
    );
    await tester.pump();
    expect(find.text('No search results'), findsOneWidget);
  });

  testWidgets('opens the selected claim and passes the exact object', (
    WidgetTester tester,
  ) async {
    final List<InsuranceClaim> claims = await MockClaimStatusRepository(
      delay: Duration.zero,
    ).getClaims();
    InsuranceClaim? selected;
    await _pumpPage(
      tester,
      repository: _FakeRepository(() async => claims),
      onClaimPressed: (InsuranceClaim claim) {
        selected = claim;
      },
    );
    await _pumpFrames(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('claim_filter_approved')),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final Finder card = find.byKey(
      const ValueKey<String>(
        'claim_card_${MockClaimStatusRepository.approvedClaimId}',
      ),
    );
    await tester.tap(card);

    expect(selected?.id, MockClaimStatusRepository.approvedClaimId);
  });

  testWidgets('shows failure and retries without recreating the page', (
    WidgetTester tester,
  ) async {
    int attempt = 0;
    final List<InsuranceClaim> claims = await MockClaimStatusRepository(
      delay: Duration.zero,
    ).getClaims();
    await _pumpPage(
      tester,
      repository: _FakeRepository(() async {
        attempt++;
        if (attempt == 1) {
          throw StateError('offline');
        }
        return claims;
      }),
    );
    await _pumpFrames(tester);

    expect(find.text('Unable to load claims'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await _pumpFrames(tester);

    expect(find.text('Unable to load claims'), findsNothing);
    expect(find.byKey(const Key('claims_summary')), findsOneWidget);
    expect(attempt, 2);
  });

  testWidgets('refresh keeps existing claims visible', (
    WidgetTester tester,
  ) async {
    final List<InsuranceClaim> claims = await MockClaimStatusRepository(
      delay: Duration.zero,
    ).getClaims();
    final Completer<List<InsuranceClaim>> refreshCompleter =
        Completer<List<InsuranceClaim>>();
    int calls = 0;
    await _pumpPage(
      tester,
      repository: _FakeRepository(() {
        calls++;
        return calls == 1
            ? Future<List<InsuranceClaim>>.value(claims)
            : refreshCompleter.future;
      }),
    );
    await _pumpFrames(tester);

    final RefreshIndicatorState indicator = tester.state<RefreshIndicatorState>(
      find.byKey(const Key('my_claims_refresh_indicator')),
    );
    final Future<void> refresh = indicator.show();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('claims_summary')), findsOneWidget);
    expect(find.byKey(const Key('my_claims_initial_loading')), findsNothing);
    expect(calls, 2);

    refreshCompleter.complete(claims);
    await refresh;
    await _pumpFrames(tester);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required ClaimStatusRepository repository,
  ValueChanged<InsuranceClaim>? onClaimPressed,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: MyClaimsPage(
        key: UniqueKey(),
        controller: MyClaimsController(repository: repository),
        onBack: () {},
        onClaimPressed: onClaimPressed ?? (InsuranceClaim claim) {},
        onFileClaim: () {},
      ),
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

class _FakeRepository implements ClaimStatusRepository {
  _FakeRepository(this.handler);

  final Future<List<InsuranceClaim>> Function() handler;
  int getClaimsCalls = 0;

  @override
  Future<List<InsuranceClaim>> getClaims() {
    getClaimsCalls++;
    return handler();
  }

  @override
  Future<InsuranceClaim?> getClaimById(String claimId) async => null;

  @override
  Future<InsuranceClaim?> getMostRecentActiveClaim() async => null;
}
