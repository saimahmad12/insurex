import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/claims/application/controllers/claim_status_controller.dart';
import 'package:insurancex/features/claims/domain/entities/additional_evidence_request.dart';
import 'package:insurancex/features/claims/domain/entities/ai_verification_result.dart';
import 'package:insurancex/features/claims/domain/entities/blockchain_claim_record.dart';
import 'package:insurancex/features/claims/domain/entities/claim_decision.dart';
import 'package:insurancex/features/claims/domain/entities/claim_image.dart';
import 'package:insurancex/features/claims/domain/entities/claim_payment.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_timeline_event.dart';
import 'package:insurancex/features/claims/domain/entities/fraud_risk_level.dart';
import 'package:insurancex/features/claims/domain/entities/incident_details.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';
import 'package:insurancex/features/claims/domain/repositories/claim_status_repository.dart';
import 'package:insurancex/features/claims/presentation/pages/claim_status_page.dart';
import 'package:insurancex/features/claims/presentation/widgets/fraud_risk_score_gauge.dart';

void main() {
  testWidgets(
    'renders header, summary, timeline, AI, evidence and blockchain',
    (WidgetTester tester) async {
      await _pumpPage(tester, initialClaim: _claim());
      await tester.pumpAndSettle();

      expect(find.text('Claim Status'), findsOneWidget);
      expect(
        find.byKey(const Key('claim_status_summary_card'), skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('CLM-TEST-001'), findsOneWidget);
      expect(find.text('Under Review'), findsWidgets);
      expect(find.byKey(const Key('claim_progress_timeline')), findsOneWidget);
      expect(
        find.byKey(const Key('timeline_completed_submitted')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('timeline_current_manualReview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('timeline_upcoming_decision')),
        findsOneWidget,
      );
      expect(find.text('Low Risk'), findsOneWidget);
      expect(
        find.byKey(const Key('ai_verification_summary_card')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('claim_evidence_preview')), findsOneWidget);
      expect(
        find.byKey(const Key('claim_blockchain_status_card')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows loading, empty, and error retry states', (
    WidgetTester tester,
  ) async {
    final Completer<InsuranceClaim?> loading = Completer<InsuranceClaim?>();
    await _pumpPage(
      tester,
      repository: _FakeRepository((String? claimId) => loading.future),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('claim_status_initial_loading')),
      findsOneWidget,
    );
    loading.complete(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('claim_status_empty')), findsOneWidget);
    expect(find.text('No active claims'), findsOneWidget);
    expect(find.text('You have not submitted a claim yet.'), findsOneWidget);

    await _pumpPage(
      tester,
      repository: _FakeRepository((String? claimId) async {
        throw StateError('offline');
      }),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('claim_status_error')), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('shows claim not found for a missing specific ID', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      claimId: 'missing-claim',
      repository: _FakeRepository((String? claimId) async => null),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('claim_status_not_found')), findsOneWidget);
    expect(find.text('Claim not found'), findsOneWidget);
    expect(find.byKey(const Key('claim_status_empty')), findsNothing);
  });

  testWidgets('pending analysis uses the pending gauge', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      initialClaim: _claim(
        status: ClaimStatus.aiAnalysisPending,
        includeAnalysis: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analysis Pending'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
    expect(find.text('Image analysis is pending.'), findsNothing);
    expect(find.textContaining('Image analysis is pending'), findsOneWidget);
  });

  testWidgets('opens submitted evidence and navigates between images', (
    WidgetTester tester,
  ) async {
    await _pumpPage(tester, initialClaim: _claim());
    await tester.pumpAndSettle();

    final Finder firstImage = find.byKey(
      const ValueKey<String>('claim_evidence_image-1'),
    );
    await tester.ensureVisible(firstImage);
    await tester.pumpAndSettle();
    await tester.tap(firstImage);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('claim_evidence_dialog')), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Next image'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 2'), findsOneWidget);
  });

  testWidgets('shows status-specific evidence, decision, and payment cards', (
    WidgetTester tester,
  ) async {
    await _pumpPage(
      tester,
      initialClaim: _claim(
        status: ClaimStatus.additionalEvidenceRequired,
        includeEvidenceRequest: true,
        score: 54,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('additional_evidence_request_card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('claim_payment_status_card')), findsNothing);
    expect(find.text('Medium Risk'), findsOneWidget);

    await _pumpPage(
      tester,
      initialClaim: _claim(
        status: ClaimStatus.approved,
        includeDecision: true,
        includePayment: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('claim_decision_card')), findsOneWidget);
    expect(find.byKey(const Key('claim_payment_status_card')), findsOneWidget);
    expect(find.text('Receive Payment'), findsOneWidget);
    expect(find.text('Rs. 105,000'), findsWidgets);

    await _pumpPage(
      tester,
      initialClaim: _claim(
        status: ClaimStatus.rejected,
        includeDecision: true,
        score: 78,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('High Risk'), findsOneWidget);
    expect(find.byKey(const Key('claim_decision_card')), findsOneWidget);
    expect(find.byKey(const Key('claim_payment_status_card')), findsNothing);
    expect(
      find.text('The incident is outside policy coverage.'),
      findsOneWidget,
    );
    expect(find.text('View Reason'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);

    await _pumpPage(
      tester,
      initialClaim: _claim(
        status: ClaimStatus.settled,
        includeDecision: true,
        includePayment: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settled'), findsWidgets);
    expect(find.byKey(const Key('claim_payment_status_card')), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.text('PAY-TEST-001'), findsOneWidget);
    expect(find.text('View Receipt'), findsOneWidget);
  });

  testWidgets(
    'refresh keeps current content visible and blocks a full loader',
    (WidgetTester tester) async {
      final InsuranceClaim currentClaim = _claim();
      final Completer<InsuranceClaim?> refresh = Completer<InsuranceClaim?>();
      int calls = 0;
      await _pumpPage(
        tester,
        repository: _FakeRepository((String? claimId) {
          calls++;
          return calls == 1
              ? Future<InsuranceClaim?>.value(currentClaim)
              : refresh.future;
        }),
        claimId: currentClaim.id,
      );
      await tester.pumpAndSettle();

      final RefreshIndicatorState indicator = tester
          .state<RefreshIndicatorState>(
            find.byKey(const Key('claim_status_refresh_indicator')),
          );
      final Future<void> refreshOperation = indicator.show();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.byKey(const Key('claim_status_summary_card'), skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('claim_status_initial_loading')),
        findsNothing,
      );
      expect(calls, 2);

      refresh.complete(currentClaim);
      await refreshOperation;
      await tester.pumpAndSettle();
      expect(find.text(currentClaim.id), findsOneWidget);
    },
  );

  testWidgets('fraud gauge clamps and announces low medium and high labels', (
    WidgetTester tester,
  ) async {
    for (final (double score, FraudRiskLevel level, String label)
        in <(double, FraudRiskLevel, String)>[
          (-10, FraudRiskLevel.low, 'Low Risk'),
          (45, FraudRiskLevel.medium, 'Medium Risk'),
          (140, FraudRiskLevel.high, 'High Risk'),
        ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: FraudRiskScoreGauge(
              score: score,
              riskLevel: level,
              analysisCompleted: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Fraud risk score.*$label')),
        findsOneWidget,
      );
    }
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  InsuranceClaim? initialClaim,
  ClaimStatusRepository? repository,
  String? claimId,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: ClaimStatusPage(
        key: UniqueKey(),
        controller: ClaimStatusController(
          repository:
              repository ?? _FakeRepository((String? claimId) async => null),
          initialClaim: initialClaim,
        ),
        claimId: claimId,
        onBack: () {},
        onFileClaim: () {},
        onContextualAction: (ClaimStatusAction action) {},
      ),
    ),
  );
}

InsuranceClaim _claim({
  ClaimStatus status = ClaimStatus.underReview,
  bool includeAnalysis = true,
  bool includeEvidenceRequest = false,
  bool includeDecision = false,
  bool includePayment = false,
  int score = 18,
}) {
  final DateTime submittedAt = DateTime(2026, 8, 26, 10, 30);
  return InsuranceClaim(
    id: 'CLM-TEST-001',
    status: status,
    policyName: 'Vehicle Insurance',
    policyNumber: 'INS-2026-001',
    incidentType: IncidentType.vehicleDamage,
    incidentDate: submittedAt.subtract(const Duration(days: 1)),
    submittedAt: submittedAt,
    estimatedClaimAmount: 120000,
    aiAnalysisStatus: includeAnalysis
        ? AiAnalysisStatus.completed
        : AiAnalysisStatus.pending,
    aiVerificationResult: includeAnalysis
        ? AiVerificationResult(
            classification: score > 60
                ? EvidenceClassification.manipulated
                : score > 30
                ? EvidenceClassification.inconclusive
                : EvidenceClassification.authentic,
            fraudRiskScore: score,
            confidenceScore: 94,
            detectedIssues: const <String>[],
            requiresManualReview: score > 30,
            modelVersion: 'test-model',
            analysisTimestamp: submittedAt.add(const Duration(minutes: 2)),
            analysedImageCount: 2,
          )
        : null,
    evidenceImages: <ClaimImage>[
      ClaimImage(
        id: 'image-1',
        fileName: 'incident-front.jpg',
        localPath: 'unavailable/incident-front.jpg',
        fileSizeBytes: 1200,
        captureTimestamp: submittedAt,
        source: ClaimImageSourceType.camera,
        uploadStatus: ClaimImageUploadStatus.uploaded,
        uploadProgress: 1,
      ),
      ClaimImage(
        id: 'image-2',
        fileName: 'incident-side.jpg',
        localPath: 'unavailable/incident-side.jpg',
        fileSizeBytes: 1200,
        captureTimestamp: submittedAt,
        source: ClaimImageSourceType.gallery,
        uploadStatus: ClaimImageUploadStatus.uploaded,
        uploadProgress: 1,
      ),
    ],
    history: <ClaimTimelineEvent>[
      ClaimTimelineEvent(
        stage: ClaimTimelineStage.submitted,
        title: 'Claim Submitted',
        state: ClaimTimelineEventState.completed,
        occurredAt: submittedAt,
      ),
      if (includeAnalysis)
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.aiAnalysis,
          title: 'AI Analysis Completed',
          state: ClaimTimelineEventState.completed,
          occurredAt: submittedAt.add(const Duration(minutes: 2)),
        ),
    ],
    additionalEvidenceRequest: includeEvidenceRequest
        ? AdditionalEvidenceRequest(
            title: 'Additional images needed',
            reason: 'Please provide a wider incident view.',
            requestedAt: submittedAt.add(const Duration(days: 1)),
          )
        : null,
    decision: includeDecision
        ? ClaimDecision(
            outcome: status == ClaimStatus.rejected
                ? ClaimDecisionOutcome.rejected
                : ClaimDecisionOutcome.approved,
            decidedAt: submittedAt.add(const Duration(days: 2)),
            message: 'A claim officer completed the review.',
            approvedAmount: status == ClaimStatus.rejected ? null : 105000,
            reason: status == ClaimStatus.rejected
                ? 'The incident is outside policy coverage.'
                : null,
          )
        : null,
    payment: includePayment
        ? ClaimPayment(
            status: status == ClaimStatus.settled
                ? ClaimPaymentStatus.paid
                : status == ClaimStatus.paymentProcessing
                ? ClaimPaymentStatus.processing
                : ClaimPaymentStatus.notStarted,
            amount: 105000,
            method: 'Bank transfer',
            transactionReference: status == ClaimStatus.approved
                ? null
                : 'PAY-TEST-001',
            paidAt: status == ClaimStatus.settled
                ? submittedAt.add(const Duration(days: 4))
                : null,
          )
        : null,
    blockchainRecord: BlockchainClaimRecord(
      status: includeAnalysis
          ? BlockchainRecordStatus.secured
          : BlockchainRecordStatus.pendingIntegration,
      verificationStatus: includeAnalysis ? 'Verified' : 'Pending Integration',
      transactionHash: includeAnalysis ? '0x123456789abcdef' : null,
      recordedAt: includeAnalysis
          ? submittedAt.add(const Duration(minutes: 3))
          : null,
    ),
  );
}

class _FakeRepository implements ClaimStatusRepository {
  _FakeRepository(this.handler);

  final Future<InsuranceClaim?> Function(String? claimId) handler;

  @override
  Future<InsuranceClaim?> getClaimById(String claimId) {
    return handler(claimId);
  }

  @override
  Future<List<InsuranceClaim>> getClaims() async => <InsuranceClaim>[];

  @override
  Future<InsuranceClaim?> getMostRecentActiveClaim() {
    return handler(null);
  }
}
