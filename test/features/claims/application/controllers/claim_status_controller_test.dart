import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/application/controllers/claim_status_controller.dart';
import 'package:insurancex/features/claims/domain/entities/ai_verification_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_payment.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_timeline_event.dart';
import 'package:insurancex/features/claims/domain/entities/incident_details.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_status_repository.dart';

void main() {
  group('ClaimStatusController', () {
    test('loads a claim by ID and guards duplicate initialization', () async {
      final Completer<InsuranceClaim?> completer = Completer<InsuranceClaim?>();
      final _FakeClaimStatusRepository repository = _FakeClaimStatusRepository(
        (String? claimId) => completer.future,
      );
      final ClaimStatusController controller = ClaimStatusController(
        repository: repository,
      );

      final Future<void> first = controller.initialize(claimId: 'claim-1');
      final Future<void> duplicate = controller.initialize(claimId: 'claim-1');

      expect(controller.loadState, ClaimStatusLoadState.loading);
      expect(repository.calls, 1);
      expect(repository.requestedIds, <String?>['claim-1']);

      completer.complete(_claim(id: 'claim-1'));
      await Future.wait(<Future<void>>[first, duplicate]);

      expect(controller.loadState, ClaimStatusLoadState.success);
      expect(controller.claim?.id, 'claim-1');
    });

    test('loads the most recent active claim when ID is absent', () async {
      final _FakeClaimStatusRepository repository = _FakeClaimStatusRepository(
        (String? claimId) async => _claim(id: 'most-recent'),
      );
      final ClaimStatusController controller = ClaimStatusController(
        repository: repository,
      );

      await controller.initialize();

      expect(repository.requestedIds, <String?>[null]);
      expect(controller.claim?.id, 'most-recent');
    });

    test('distinguishes no active claim from a claim not found', () async {
      final ClaimStatusController emptyController = ClaimStatusController(
        repository: _FakeClaimStatusRepository((String? claimId) async => null),
      );
      await emptyController.initialize();
      expect(emptyController.loadState, ClaimStatusLoadState.empty);

      final ClaimStatusController notFoundController = ClaimStatusController(
        repository: _FakeClaimStatusRepository((String? claimId) async => null),
      );
      await notFoundController.initialize(claimId: 'missing-claim');
      expect(notFoundController.loadState, ClaimStatusLoadState.notFound);
    });

    test(
      'retries an initial failure without recreating the controller',
      () async {
        int attempts = 0;
        final ClaimStatusController failureController = ClaimStatusController(
          repository: _FakeClaimStatusRepository((String? claimId) async {
            attempts++;
            if (attempts == 1) {
              throw StateError('offline');
            }
            return _claim(id: claimId ?? 'claim-1');
          }),
        );
        await failureController.initialize(claimId: 'claim-1');
        expect(failureController.loadState, ClaimStatusLoadState.failure);
        expect(failureController.errorMessage, isNotNull);

        await failureController.retry();
        expect(failureController.loadState, ClaimStatusLoadState.success);
        expect(failureController.claim?.id, 'claim-1');
        expect(attempts, 2);
      },
    );

    test(
      'refresh preserves current data and prevents duplicate requests',
      () async {
        final InsuranceClaim existing = _claim(id: 'claim-1');
        final Completer<InsuranceClaim?> refreshCompleter =
            Completer<InsuranceClaim?>();
        int request = 0;
        final _FakeClaimStatusRepository repository =
            _FakeClaimStatusRepository((String? claimId) {
              request++;
              return request == 1
                  ? Future<InsuranceClaim?>.value(existing)
                  : refreshCompleter.future;
            });
        final ClaimStatusController controller = ClaimStatusController(
          repository: repository,
        );
        await controller.initialize(claimId: existing.id);

        final Future<void> refresh = controller.refresh();
        final Future<void> duplicate = controller.refresh();

        expect(controller.isRefreshing, isTrue);
        expect(controller.claim, same(existing));
        expect(repository.calls, 2);

        final InsuranceClaim updated = _claim(
          id: 'claim-1',
          status: ClaimStatus.approved,
        );
        refreshCompleter.complete(updated);
        await Future.wait(<Future<void>>[refresh, duplicate]);

        expect(controller.isRefreshing, isFalse);
        expect(controller.claim?.status, ClaimStatus.approved);
      },
    );

    test(
      'failed refresh preserves existing claim and exposes inline error',
      () async {
        int request = 0;
        final InsuranceClaim existing = _claim(id: 'claim-1');
        final ClaimStatusController controller = ClaimStatusController(
          repository: _FakeClaimStatusRepository((String? claimId) async {
            request++;
            if (request == 1) {
              return existing;
            }
            throw StateError('offline');
          }),
        );
        await controller.initialize(claimId: existing.id);

        await controller.refresh();

        expect(controller.claim, same(existing));
        expect(controller.refreshErrorMessage, isNotNull);
        expect(controller.loadState, ClaimStatusLoadState.success);
      },
    );

    test('selects contextual actions for every lifecycle status', () async {
      final Map<ClaimStatus, ClaimStatusAction> expected =
          <ClaimStatus, ClaimStatusAction>{
            ClaimStatus.submitted: ClaimStatusAction.viewSubmittedInformation,
            ClaimStatus.aiAnalysisPending:
                ClaimStatusAction.viewAnalysisProgress,
            ClaimStatus.aiAnalysisCompleted: ClaimStatusAction.contactSupport,
            ClaimStatus.underReview: ClaimStatusAction.contactSupport,
            ClaimStatus.additionalEvidenceRequired:
                ClaimStatusAction.uploadEvidence,
            ClaimStatus.approved: ClaimStatusAction.viewDecision,
            ClaimStatus.rejected: ClaimStatusAction.viewReason,
            ClaimStatus.paymentProcessing: ClaimStatusAction.viewPaymentStatus,
            ClaimStatus.settled: ClaimStatusAction.viewReceipt,
          };

      for (final MapEntry<ClaimStatus, ClaimStatusAction> entry
          in expected.entries) {
        final ClaimStatusController controller = ClaimStatusController(
          repository: _FakeClaimStatusRepository(
            (String? claimId) async => null,
          ),
          initialClaim: _claim(status: entry.key),
        );
        await controller.initialize();
        expect(controller.contextualAction, entry.value);
      }
    });

    test(
      'high risk requires manual review and payment visibility is specific',
      () async {
        final ClaimStatusController highRisk = ClaimStatusController(
          repository: _FakeClaimStatusRepository(
            (String? claimId) async => null,
          ),
          initialClaim: _claim(riskScore: 78),
        );
        final ClaimStatusController approved = ClaimStatusController(
          repository: _FakeClaimStatusRepository(
            (String? claimId) async => null,
          ),
          initialClaim: _claim(
            status: ClaimStatus.approved,
            includePayment: true,
          ),
        );
        final ClaimStatusController underReview = ClaimStatusController(
          repository: _FakeClaimStatusRepository(
            (String? claimId) async => null,
          ),
          initialClaim: _claim(status: ClaimStatus.underReview),
        );

        expect(highRisk.requiresManualReview, isTrue);
        expect(approved.showPaymentCard, isTrue);
        expect(underReview.showPaymentCard, isFalse);
      },
    );
  });
}

InsuranceClaim _claim({
  String id = 'claim-1',
  ClaimStatus status = ClaimStatus.underReview,
  int riskScore = 18,
  bool includePayment = false,
}) {
  final DateTime submittedAt = DateTime(2026, 8, 26, 10, 30);
  return InsuranceClaim(
    id: id,
    status: status,
    policyName: 'Vehicle Insurance',
    policyNumber: 'INS-001',
    incidentType: IncidentType.vehicleDamage,
    incidentDate: submittedAt.subtract(const Duration(days: 1)),
    submittedAt: submittedAt,
    estimatedClaimAmount: 120000,
    aiAnalysisStatus: AiAnalysisStatus.completed,
    aiVerificationResult: AiVerificationResult(
      classification: EvidenceClassification.authentic,
      fraudRiskScore: riskScore,
      confidenceScore: 94,
      detectedIssues: const <String>[],
      requiresManualReview: false,
      modelVersion: 'test-model',
      analysisTimestamp: submittedAt.add(const Duration(minutes: 2)),
      analysedImageCount: 2,
    ),
    evidenceImages: const [],
    history: <ClaimTimelineEvent>[
      ClaimTimelineEvent(
        stage: ClaimTimelineStage.submitted,
        title: 'Claim Submitted',
        state: ClaimTimelineEventState.completed,
        occurredAt: submittedAt,
      ),
    ],
    payment: includePayment
        ? const ClaimPayment(
            status: ClaimPaymentStatus.notStarted,
            amount: 105000,
          )
        : null,
  );
}

class _FakeClaimStatusRepository implements ClaimStatusRepository {
  _FakeClaimStatusRepository(this.handler);

  final Future<InsuranceClaim?> Function(String? claimId) handler;
  final List<String?> requestedIds = <String?>[];
  int calls = 0;

  @override
  Future<InsuranceClaim?> getClaimById(String claimId) {
    calls++;
    requestedIds.add(claimId);
    return handler(claimId);
  }

  @override
  Future<List<InsuranceClaim>> getClaims() async => <InsuranceClaim>[];

  @override
  Future<InsuranceClaim?> getMostRecentActiveClaim() {
    calls++;
    requestedIds.add(null);
    return handler(null);
  }
}
