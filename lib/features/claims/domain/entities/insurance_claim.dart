import 'additional_evidence_request.dart';
import 'ai_verification_result.dart';
import 'blockchain_claim_record.dart';
import 'claim_decision.dart';
import 'claim_image.dart';
import 'claim_payment.dart';
import 'claim_submission_result.dart';
import 'claim_timeline_event.dart';
import 'incident_details.dart';

class InsuranceClaim {
  const InsuranceClaim({
    required this.id,
    required this.status,
    required this.policyName,
    required this.policyNumber,
    required this.incidentType,
    required this.incidentDate,
    required this.submittedAt,
    required this.estimatedClaimAmount,
    required this.aiAnalysisStatus,
    required this.evidenceImages,
    required this.history,
    this.aiVerificationResult,
    this.additionalEvidenceRequest,
    this.decision,
    this.payment,
    this.blockchainRecord,
    this.belongsToCurrentUser = true,
  });

  final String id;
  final ClaimStatus status;
  final String policyName;
  final String policyNumber;
  final IncidentType incidentType;
  final DateTime incidentDate;
  final DateTime submittedAt;
  final double estimatedClaimAmount;
  final AiAnalysisStatus aiAnalysisStatus;
  final AiVerificationResult? aiVerificationResult;
  final List<ClaimImage> evidenceImages;
  final List<ClaimTimelineEvent> history;
  final AdditionalEvidenceRequest? additionalEvidenceRequest;
  final ClaimDecision? decision;
  final ClaimPayment? payment;
  final BlockchainClaimRecord? blockchainRecord;
  final bool belongsToCurrentUser;

  double? get approvedAmount => decision?.approvedAmount;

  DateTime get lastUpdatedAt {
    DateTime latest = submittedAt;
    final List<DateTime?> candidates = <DateTime?>[
      aiVerificationResult?.analysisTimestamp,
      additionalEvidenceRequest?.requestedAt,
      decision?.decidedAt,
      payment?.paidAt,
      blockchainRecord?.recordedAt,
      ...history.map((ClaimTimelineEvent event) => event.occurredAt),
    ];

    for (final DateTime? candidate in candidates) {
      if (candidate != null && candidate.isAfter(latest)) {
        latest = candidate;
      }
    }
    return latest;
  }
}
