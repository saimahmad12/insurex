import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/claims/application/services/claim_timeline_builder.dart';
import 'package:insurancex/features/claims/domain/entities/ai_verification_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_submission_result.dart';
import 'package:insurancex/features/claims/domain/entities/claim_timeline_event.dart';
import 'package:insurancex/features/claims/domain/entities/incident_details.dart';
import 'package:insurancex/features/claims/domain/entities/insurance_claim.dart';

void main() {
  test('generates a status-specific timeline for every claim status', () {
    for (final ClaimStatus status in ClaimStatus.values) {
      final List<ClaimTimelineEvent> timeline = ClaimTimelineBuilder.build(
        _claim(status),
      );

      expect(timeline, isNotEmpty, reason: status.name);
      expect(
        timeline.where(
          (ClaimTimelineEvent event) =>
              event.state == ClaimTimelineEventState.current,
        ),
        hasLength(1),
        reason: status.name,
      );
      expect(
        timeline
            .where(
              (ClaimTimelineEvent event) =>
                  event.state == ClaimTimelineEventState.upcoming,
            )
            .every((ClaimTimelineEvent event) => event.occurredAt == null),
        isTrue,
        reason: status.name,
      );
    }
  });

  test('rejection ends at the decision and evidence appears at review', () {
    final List<ClaimTimelineEvent> rejected = ClaimTimelineBuilder.build(
      _claim(ClaimStatus.rejected),
    );
    final List<ClaimTimelineEvent> evidence = ClaimTimelineBuilder.build(
      _claim(ClaimStatus.additionalEvidenceRequired),
    );

    expect(rejected.last.stage, ClaimTimelineStage.decision);
    expect(
      rejected.any(
        (ClaimTimelineEvent event) => event.stage == ClaimTimelineStage.payment,
      ),
      isFalse,
    );
    expect(
      evidence.any(
        (ClaimTimelineEvent event) =>
            event.stage == ClaimTimelineStage.additionalEvidence &&
            event.state == ClaimTimelineEventState.current,
      ),
      isTrue,
    );
  });
}

InsuranceClaim _claim(ClaimStatus status) {
  final DateTime submittedAt = DateTime(2026, 8, 26, 10, 30);
  return InsuranceClaim(
    id: 'claim-${status.name}',
    status: status,
    policyName: 'Vehicle Insurance',
    policyNumber: 'INS-001',
    incidentType: IncidentType.vehicleDamage,
    incidentDate: submittedAt.subtract(const Duration(days: 1)),
    submittedAt: submittedAt,
    estimatedClaimAmount: 120000,
    aiAnalysisStatus:
        status == ClaimStatus.submitted ||
            status == ClaimStatus.aiAnalysisPending
        ? AiAnalysisStatus.pending
        : AiAnalysisStatus.completed,
    evidenceImages: const [],
    history: <ClaimTimelineEvent>[
      ClaimTimelineEvent(
        stage: ClaimTimelineStage.submitted,
        title: 'Claim Submitted',
        state: ClaimTimelineEventState.completed,
        occurredAt: submittedAt,
      ),
    ],
  );
}
