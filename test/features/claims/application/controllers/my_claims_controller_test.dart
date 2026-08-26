import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/application/controllers/my_claims_controller.dart';
import 'package:insurancex/features/claims/domain/entities/ai_verification_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_filter.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_timeline_event.dart';
import 'package:insurancex/features/claims/domain/entities/incident_details.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_status_repository.dart';

void main() {
  group('MyClaimsController', () {
    test('loads all claims once and exposes summary counts', () async {
      final _FakeClaimsRepository repository = _FakeClaimsRepository(
        handler: () async => _claims(),
      );
      final MyClaimsController controller = MyClaimsController(
        repository: repository,
      );

      await Future.wait(<Future<void>>[
        controller.initialize(),
        controller.initialize(),
      ]);

      expect(repository.getClaimsCalls, 1);
      expect(controller.loadStatus, MyClaimsLoadStatus.success);
      expect(controller.totalClaimsCount, 9);
      expect(controller.activeClaimsCount, 6);
      expect(controller.approvedClaimsCount, 1);
      expect(controller.settledClaimsCount, 1);
    });

    test('applies every status filter without repository calls', () async {
      final _FakeClaimsRepository repository = _FakeClaimsRepository(
        handler: () async => _claims(),
      );
      final MyClaimsController controller = MyClaimsController(
        repository: repository,
      );
      await controller.initialize();

      final Map<ClaimFilter, List<ClaimStatus>> expected =
          <ClaimFilter, List<ClaimStatus>>{
            ClaimFilter.all: <ClaimStatus>[
              ClaimStatus.submitted,
              ClaimStatus.aiAnalysisPending,
              ClaimStatus.aiAnalysisCompleted,
              ClaimStatus.underReview,
              ClaimStatus.additionalEvidenceRequired,
              ClaimStatus.approved,
              ClaimStatus.paymentProcessing,
              ClaimStatus.rejected,
              ClaimStatus.settled,
            ],
            ClaimFilter.active: <ClaimStatus>[
              ClaimStatus.submitted,
              ClaimStatus.aiAnalysisPending,
              ClaimStatus.aiAnalysisCompleted,
              ClaimStatus.underReview,
              ClaimStatus.additionalEvidenceRequired,
              ClaimStatus.paymentProcessing,
            ],
            ClaimFilter.approved: <ClaimStatus>[ClaimStatus.approved],
            ClaimFilter.rejected: <ClaimStatus>[ClaimStatus.rejected],
            ClaimFilter.settled: <ClaimStatus>[ClaimStatus.settled],
          };

      for (final MapEntry<ClaimFilter, List<ClaimStatus>> entry
          in expected.entries) {
        controller.changeFilter(entry.key);
        expect(
          controller.visibleClaims.map((InsuranceClaim claim) => claim.status),
          orderedEquals(entry.value),
        );
      }
      expect(repository.getClaimsCalls, 1);
    });

    test('searches by ID, policy, policy number, and incident type', () async {
      final _FakeClaimsRepository repository = _FakeClaimsRepository(
        handler: () async => _claims(),
      );
      final MyClaimsController controller = MyClaimsController(
        repository: repository,
      );
      await controller.initialize();

      for (final (String query, String expectedId) in <(String, String)>[
        ('CLM-3', 'CLM-3'),
        ('Health', 'CLM-2'),
        ('POL-TRAVEL', 'CLM-4'),
        ('baggage loss', 'CLM-4'),
      ]) {
        controller.updateSearchQuery(query);
        expect(controller.visibleClaims.single.id, expectedId);
      }
      expect(repository.getClaimsCalls, 1);
    });

    test('combines search and filtering and exposes empty results', () async {
      final MyClaimsController controller = MyClaimsController(
        repository: _FakeClaimsRepository(handler: () async => _claims()),
      );
      await controller.initialize();

      controller.changeFilter(ClaimFilter.rejected);
      controller.updateSearchQuery('Vehicle');
      expect(controller.visibleClaims.single.id, 'CLM-7');

      controller.updateSearchQuery('Health');
      expect(controller.visibleClaims, isEmpty);

      controller.clearSearch();
      controller.changeFilter(ClaimFilter.settled);
      expect(controller.visibleClaims.single.status, ClaimStatus.settled);
    });

    test('represents empty data and empty filtered categories', () async {
      final MyClaimsController emptyController = MyClaimsController(
        repository: _FakeClaimsRepository(
          handler: () async => <InsuranceClaim>[],
        ),
      );
      await emptyController.initialize();
      expect(emptyController.loadStatus, MyClaimsLoadStatus.empty);
      expect(emptyController.visibleClaims, isEmpty);

      final MyClaimsController filteredController = MyClaimsController(
        repository: _FakeClaimsRepository(
          handler: () async => <InsuranceClaim>[
            _claim(id: 'active', status: ClaimStatus.submitted),
          ],
        ),
      );
      await filteredController.initialize();
      filteredController.changeFilter(ClaimFilter.rejected);
      expect(filteredController.visibleClaims, isEmpty);
    });

    test('retries an initial failure', () async {
      int attempt = 0;
      final MyClaimsController controller = MyClaimsController(
        repository: _FakeClaimsRepository(
          handler: () async {
            attempt++;
            if (attempt == 1) {
              throw StateError('offline');
            }
            return _claims();
          },
        ),
      );

      await controller.initialize();
      expect(controller.loadStatus, MyClaimsLoadStatus.failure);
      await controller.retry();
      expect(controller.loadStatus, MyClaimsLoadStatus.success);
      expect(attempt, 2);
    });

    test('refresh preserves data and prevents duplicate requests', () async {
      final Completer<List<InsuranceClaim>> refreshCompleter =
          Completer<List<InsuranceClaim>>();
      int request = 0;
      final _FakeClaimsRepository repository = _FakeClaimsRepository(
        handler: () {
          request++;
          return request == 1
              ? Future<List<InsuranceClaim>>.value(_claims())
              : refreshCompleter.future;
        },
      );
      final MyClaimsController controller = MyClaimsController(
        repository: repository,
      );
      await controller.initialize();
      controller.changeFilter(ClaimFilter.rejected);
      controller.updateSearchQuery('Vehicle');

      final Future<void> refresh = controller.refresh();
      final Future<void> duplicate = controller.refresh();

      expect(controller.isRefreshing, isTrue);
      expect(controller.claims, isNotEmpty);
      expect(repository.getClaimsCalls, 2);
      expect(controller.selectedFilter, ClaimFilter.rejected);
      expect(controller.searchQuery, 'Vehicle');

      refreshCompleter.complete(<InsuranceClaim>[
        _claim(id: 'updated', status: ClaimStatus.rejected),
      ]);
      await Future.wait(<Future<void>>[refresh, duplicate]);

      expect(controller.isRefreshing, isFalse);
      expect(controller.claims.single.id, 'updated');
      expect(controller.selectedFilter, ClaimFilter.rejected);
      expect(controller.searchQuery, 'Vehicle');
    });

    test('failed refresh preserves claims and exposes refresh error', () async {
      int request = 0;
      final MyClaimsController controller = MyClaimsController(
        repository: _FakeClaimsRepository(
          handler: () async {
            request++;
            if (request > 1) {
              throw StateError('offline');
            }
            return _claims();
          },
        ),
      );
      await controller.initialize();
      final List<InsuranceClaim> existing = controller.claims;

      await controller.refresh();

      expect(controller.claims, same(existing));
      expect(controller.refreshStatus, ClaimsRefreshStatus.failure);
      expect(controller.refreshErrorMessage, isNotNull);
      expect(controller.loadStatus, MyClaimsLoadStatus.success);
    });
  });
}

List<InsuranceClaim> _claims() {
  return <InsuranceClaim>[
    _claim(id: 'CLM-1', status: ClaimStatus.submitted),
    _claim(
      id: 'CLM-2',
      status: ClaimStatus.aiAnalysisPending,
      policyName: 'Health Insurance',
      policyNumber: 'POL-HEALTH',
      incidentType: IncidentType.hospitalization,
    ),
    _claim(id: 'CLM-2B', status: ClaimStatus.aiAnalysisCompleted),
    _claim(id: 'CLM-3', status: ClaimStatus.underReview),
    _claim(
      id: 'CLM-4',
      status: ClaimStatus.additionalEvidenceRequired,
      policyName: 'Travel Insurance',
      policyNumber: 'POL-TRAVEL',
      incidentType: IncidentType.baggageLoss,
    ),
    _claim(id: 'CLM-5', status: ClaimStatus.approved),
    _claim(id: 'CLM-6', status: ClaimStatus.paymentProcessing),
    _claim(id: 'CLM-7', status: ClaimStatus.rejected),
    _claim(id: 'CLM-8', status: ClaimStatus.settled),
  ];
}

InsuranceClaim _claim({
  required String id,
  required ClaimStatus status,
  String policyName = 'Vehicle Insurance',
  String policyNumber = 'POL-VEHICLE',
  IncidentType incidentType = IncidentType.vehicleDamage,
}) {
  final DateTime submittedAt = DateTime(2026, 8, 20);
  return InsuranceClaim(
    id: id,
    status: status,
    policyName: policyName,
    policyNumber: policyNumber,
    incidentType: incidentType,
    incidentDate: submittedAt,
    submittedAt: submittedAt,
    estimatedClaimAmount: 100000,
    aiAnalysisStatus: AiAnalysisStatus.pending,
    evidenceImages: const [],
    history: <ClaimTimelineEvent>[
      ClaimTimelineEvent(
        stage: ClaimTimelineStage.submitted,
        title: 'Submitted',
        state: ClaimTimelineEventState.completed,
        occurredAt: submittedAt,
      ),
    ],
  );
}

class _FakeClaimsRepository implements ClaimStatusRepository {
  _FakeClaimsRepository({required this.handler});

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
