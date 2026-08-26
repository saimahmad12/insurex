import '../../domain/entities/additional_evidence_request.dart';
import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/blockchain_claim_record.dart';
import '../../domain/entities/claim_decision.dart';
import '../../domain/entities/claim_filter.dart';
import '../../domain/entities/claim_image.dart';
import '../../domain/entities/claim_payment.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/claim_timeline_event.dart';
import '../../domain/entities/incident_details.dart';
import '../../domain/entities/insurance_claim.dart';
import '../../domain/repositories/claim_status_repository.dart';

class MockClaimStatusRepository implements ClaimStatusRepository {
  MockClaimStatusRepository({
    this.delay = const Duration(milliseconds: 450),
    this.failLoading = false,
    List<InsuranceClaim>? claims,
  }) : _claims = claims == null
           ? _defaultClaims
           : List<InsuranceClaim>.of(claims);

  static const String submittedClaimId = 'CLM20260826008';
  static const String underReviewClaimId = 'CLM20260826001';
  static const String aiPendingClaimId = 'CLM20260825002';
  static const String additionalEvidenceClaimId = 'CLM20260824003';
  static const String approvedClaimId = 'CLM20260823004';
  static const String rejectedClaimId = 'CLM20260822005';
  static const String paymentProcessingClaimId = 'CLM20260821006';
  static const String settledClaimId = 'CLM20260820007';

  final Duration delay;
  final bool failLoading;
  final List<InsuranceClaim> _claims;

  static final List<InsuranceClaim> _defaultClaims = <InsuranceClaim>[
    _claim(
      id: submittedClaimId,
      status: ClaimStatus.submitted,
      submittedAt: DateTime(2026, 8, 26, 9, 15),
      policyName: 'Travel Insurance',
      policyNumber: 'INS-2026-003',
      incidentType: IncidentType.baggageLoss,
      estimatedClaimAmount: 85000,
    ),
    _claim(
      id: underReviewClaimId,
      status: ClaimStatus.underReview,
      submittedAt: DateTime(2026, 8, 26, 10, 30),
      riskScore: 18,
      classification: EvidenceClassification.authentic,
      requiresManualReview: true,
    ),
    _claim(
      id: aiPendingClaimId,
      status: ClaimStatus.aiAnalysisPending,
      submittedAt: DateTime(2026, 8, 25, 15, 10),
      policyName: 'Health Insurance',
      policyNumber: 'INS-2026-002',
      incidentType: IncidentType.hospitalization,
      estimatedClaimAmount: 180000,
    ),
    _claim(
      id: additionalEvidenceClaimId,
      status: ClaimStatus.additionalEvidenceRequired,
      submittedAt: DateTime(2026, 8, 24, 9, 20),
      riskScore: 54,
      classification: EvidenceClassification.inconclusive,
      requiresManualReview: true,
    ),
    _claim(
      id: approvedClaimId,
      status: ClaimStatus.approved,
      submittedAt: DateTime(2026, 8, 23, 11, 5),
      riskScore: 11,
      classification: EvidenceClassification.authentic,
      policyName: 'Travel Insurance',
      policyNumber: 'INS-2025-017',
      incidentType: IncidentType.tripCancellation,
      estimatedClaimAmount: 95000,
    ),
    _claim(
      id: rejectedClaimId,
      status: ClaimStatus.rejected,
      submittedAt: DateTime(2026, 8, 22, 14, 45),
      riskScore: 78,
      classification: EvidenceClassification.manipulated,
      requiresManualReview: true,
    ),
    _claim(
      id: paymentProcessingClaimId,
      status: ClaimStatus.paymentProcessing,
      submittedAt: DateTime(2026, 8, 21, 12, 15),
      riskScore: 16,
      classification: EvidenceClassification.authentic,
    ),
    _claim(
      id: settledClaimId,
      status: ClaimStatus.settled,
      submittedAt: DateTime(2026, 8, 20, 8, 40),
      riskScore: 8,
      classification: EvidenceClassification.authentic,
    ),
  ];

  @override
  Future<List<InsuranceClaim>> getClaims() async {
    await _waitForMockResponse();
    _throwIfLoadingFails();

    final List<InsuranceClaim> claims = List<InsuranceClaim>.of(_claims)
      ..sort(
        (InsuranceClaim first, InsuranceClaim second) =>
            second.lastUpdatedAt.compareTo(first.lastUpdatedAt),
      );
    return List<InsuranceClaim>.unmodifiable(claims);
  }

  @override
  Future<InsuranceClaim?> getClaimById(String claimId) async {
    await _waitForMockResponse();
    _throwIfLoadingFails();

    for (final InsuranceClaim claim in _claims) {
      if (claim.id == claimId) {
        return claim;
      }
    }

    if (claimId.startsWith('CLM-')) {
      final InsuranceClaim submittedClaim = _claim(
        id: claimId,
        status: ClaimStatus.underReview,
        submittedAt: DateTime.now(),
        riskScore: 20,
        classification: EvidenceClassification.authentic,
        requiresManualReview: true,
      );
      _claims.add(submittedClaim);
      return submittedClaim;
    }
    return null;
  }

  @override
  Future<InsuranceClaim?> getMostRecentActiveClaim() async {
    await _waitForMockResponse();
    _throwIfLoadingFails();

    final List<InsuranceClaim> activeClaims =
        _claims.where((InsuranceClaim claim) {
          return claim.status.isActiveClaim;
        }).toList()..sort(
          (InsuranceClaim first, InsuranceClaim second) =>
              second.lastUpdatedAt.compareTo(first.lastUpdatedAt),
        );

    return activeClaims.isEmpty ? null : activeClaims.first;
  }

  void _throwIfLoadingFails() {
    if (failLoading) {
      throw StateError('Unable to load claims.');
    }
  }

  Future<void> _waitForMockResponse() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  static InsuranceClaim _claim({
    required String id,
    required ClaimStatus status,
    required DateTime submittedAt,
    int? riskScore,
    EvidenceClassification classification = EvidenceClassification.authentic,
    bool requiresManualReview = false,
    String policyName = 'Vehicle Insurance',
    String policyNumber = 'INS-2026-001',
    IncidentType incidentType = IncidentType.vehicleDamage,
    double estimatedClaimAmount = 120000,
  }) {
    final bool analysisCompleted = riskScore != null;
    final DateTime analysisTime = submittedAt.add(const Duration(minutes: 2));
    final DateTime decisionTime = submittedAt.add(const Duration(days: 2));
    final bool approved =
        status == ClaimStatus.approved ||
        status == ClaimStatus.paymentProcessing ||
        status == ClaimStatus.settled;
    final bool rejected = status == ClaimStatus.rejected;

    return InsuranceClaim(
      id: id,
      status: status,
      policyName: policyName,
      policyNumber: policyNumber,
      incidentType: incidentType,
      incidentDate: submittedAt.subtract(const Duration(days: 1, hours: 3)),
      submittedAt: submittedAt,
      estimatedClaimAmount: estimatedClaimAmount,
      aiAnalysisStatus: analysisCompleted
          ? AiAnalysisStatus.completed
          : AiAnalysisStatus.pending,
      aiVerificationResult: analysisCompleted
          ? AiVerificationResult(
              classification: classification,
              fraudRiskScore: riskScore,
              confidenceScore:
                  classification == EvidenceClassification.inconclusive
                  ? 63
                  : 94,
              detectedIssues: classification == EvidenceClassification.authentic
                  ? const <String>[]
                  : const <String>['Evidence requires claim officer review.'],
              requiresManualReview: requiresManualReview || riskScore > 30,
              modelVersion: 'InsureX Vision 1.4',
              analysisTimestamp: analysisTime,
              analysedImageCount: 2,
            )
          : null,
      evidenceImages: _evidenceImages(submittedAt),
      history: _history(status, submittedAt, analysisTime, decisionTime),
      additionalEvidenceRequest:
          status == ClaimStatus.additionalEvidenceRequired
          ? AdditionalEvidenceRequest(
              title: 'Additional incident evidence needed',
              reason:
                  'Please provide a wider view of the damaged vehicle and the surrounding incident area.',
              requestedAt: submittedAt.add(const Duration(days: 1, hours: 2)),
              submissionDeadline: submittedAt.add(const Duration(days: 8)),
            )
          : null,
      decision: approved
          ? ClaimDecision(
              outcome: ClaimDecisionOutcome.approved,
              decidedAt: decisionTime,
              approvedAmount: 105000,
              message:
                  'Your claim was approved after review of the submitted information.',
            )
          : rejected
          ? ClaimDecision(
              outcome: ClaimDecisionOutcome.rejected,
              decidedAt: decisionTime,
              reason:
                  'The documented incident falls outside the selected policy coverage.',
              message:
                  'A claim officer completed the review. Contact support if you need clarification.',
            )
          : null,
      payment: approved
          ? ClaimPayment(
              status: status == ClaimStatus.approved
                  ? ClaimPaymentStatus.notStarted
                  : status == ClaimStatus.paymentProcessing
                  ? ClaimPaymentStatus.processing
                  : ClaimPaymentStatus.paid,
              amount: 105000,
              method: 'Bank transfer',
              transactionReference: status == ClaimStatus.approved
                  ? null
                  : 'PAY-2026-${id.substring(id.length - 3)}',
              paidAt: status == ClaimStatus.settled
                  ? decisionTime.add(const Duration(days: 2))
                  : null,
            )
          : null,
      blockchainRecord: BlockchainClaimRecord(
        status: analysisCompleted
            ? BlockchainRecordStatus.secured
            : BlockchainRecordStatus.pendingIntegration,
        verificationStatus: analysisCompleted
            ? 'Verified'
            : 'Pending Integration',
        transactionHash: analysisCompleted
            ? '0x8f3a21cd98472ad03d9f76b2e1854ac9b67bd9'
            : null,
        recordedAt: analysisCompleted
            ? submittedAt.add(const Duration(minutes: 3))
            : null,
      ),
    );
  }

  static List<ClaimImage> _evidenceImages(DateTime submittedAt) {
    return <ClaimImage>[
      ClaimImage(
        id: 'evidence-front-${submittedAt.microsecondsSinceEpoch}',
        fileName: 'vehicle_damage_front.jpg',
        localPath: 'submitted-evidence/vehicle_damage_front.jpg',
        fileSizeBytes: 1840000,
        captureTimestamp: submittedAt.subtract(const Duration(hours: 4)),
        source: ClaimImageSourceType.camera,
        uploadStatus: ClaimImageUploadStatus.uploaded,
        uploadProgress: 1,
      ),
      ClaimImage(
        id: 'evidence-side-${submittedAt.microsecondsSinceEpoch}',
        fileName: 'vehicle_damage_side.jpg',
        localPath: 'submitted-evidence/vehicle_damage_side.jpg',
        fileSizeBytes: 1630000,
        captureTimestamp: submittedAt.subtract(const Duration(hours: 4)),
        source: ClaimImageSourceType.gallery,
        uploadStatus: ClaimImageUploadStatus.uploaded,
        uploadProgress: 1,
      ),
    ];
  }

  static List<ClaimTimelineEvent> _history(
    ClaimStatus status,
    DateTime submittedAt,
    DateTime analysisTime,
    DateTime decisionTime,
  ) {
    final List<ClaimTimelineEvent> events = <ClaimTimelineEvent>[
      ClaimTimelineEvent(
        stage: ClaimTimelineStage.submitted,
        title: 'Claim Submitted',
        state: ClaimTimelineEventState.completed,
        occurredAt: submittedAt,
      ),
    ];

    if (status.index >= ClaimStatus.aiAnalysisCompleted.index) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.aiAnalysis,
          title: 'AI Analysis Completed',
          state: ClaimTimelineEventState.completed,
          occurredAt: analysisTime,
        ),
      );
    }
    if (status.index >= ClaimStatus.underReview.index) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.manualReview,
          title: 'Manual Review Started',
          state: ClaimTimelineEventState.completed,
          occurredAt: analysisTime.add(const Duration(minutes: 13)),
        ),
      );
    }
    if (status == ClaimStatus.additionalEvidenceRequired) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.additionalEvidence,
          title: 'Additional Evidence Required',
          state: ClaimTimelineEventState.completed,
          occurredAt: submittedAt.add(const Duration(days: 1, hours: 2)),
        ),
      );
    }
    if (status == ClaimStatus.approved ||
        status == ClaimStatus.rejected ||
        status == ClaimStatus.paymentProcessing ||
        status == ClaimStatus.settled) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.decision,
          title: status == ClaimStatus.rejected
              ? 'Claim Rejected'
              : 'Claim Approved',
          state: ClaimTimelineEventState.completed,
          occurredAt: decisionTime,
        ),
      );
    }
    if (status == ClaimStatus.paymentProcessing ||
        status == ClaimStatus.settled) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.payment,
          title: 'Payment Processing',
          state: ClaimTimelineEventState.completed,
          occurredAt: decisionTime.add(const Duration(hours: 3)),
        ),
      );
    }
    if (status == ClaimStatus.settled) {
      events.add(
        ClaimTimelineEvent(
          stage: ClaimTimelineStage.settlement,
          title: 'Claim Settled',
          state: ClaimTimelineEventState.completed,
          occurredAt: decisionTime.add(const Duration(days: 2)),
        ),
      );
    }
    return events;
  }
}
