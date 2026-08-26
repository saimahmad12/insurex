import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/claim_submission_result.dart';
import '../../domain/entities/claim_timeline_event.dart';
import '../../domain/entities/insurance_claim.dart';

abstract final class ClaimTimelineBuilder {
  static List<ClaimTimelineEvent> build(InsuranceClaim claim) {
    switch (claim.status) {
      case ClaimStatus.submitted:
        return <ClaimTimelineEvent>[
          _item(
            claim,
            ClaimTimelineStage.submitted,
            'Claim Submitted',
            ClaimTimelineEventState.current,
            fallbackTime: claim.submittedAt,
          ),
          _upcoming(ClaimTimelineStage.aiAnalysis, 'AI Analysis Pending'),
          _upcoming(ClaimTimelineStage.manualReview, 'Review Pending'),
          _upcoming(ClaimTimelineStage.decision, 'Decision Pending'),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.aiAnalysisPending:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _item(
            claim,
            ClaimTimelineStage.aiAnalysis,
            claim.aiAnalysisStatus == AiAnalysisStatus.failed
                ? 'AI Analysis Needs Attention'
                : 'AI Analysis in Progress',
            ClaimTimelineEventState.current,
          ),
          _upcoming(ClaimTimelineStage.manualReview, 'Review Pending'),
          _upcoming(ClaimTimelineStage.decision, 'Decision Pending'),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.aiAnalysisCompleted:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _item(
            claim,
            ClaimTimelineStage.aiAnalysis,
            'AI Analysis Completed',
            ClaimTimelineEventState.current,
          ),
          _upcoming(ClaimTimelineStage.manualReview, 'Review Pending'),
          _upcoming(ClaimTimelineStage.decision, 'Decision Pending'),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.underReview:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _item(
            claim,
            ClaimTimelineStage.manualReview,
            'Under Review',
            ClaimTimelineEventState.current,
          ),
          _upcoming(ClaimTimelineStage.decision, 'Decision Pending'),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.additionalEvidenceRequired:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _item(
            claim,
            ClaimTimelineStage.manualReview,
            'Manual Review',
            ClaimTimelineEventState.completed,
          ),
          _item(
            claim,
            ClaimTimelineStage.additionalEvidence,
            'Additional Evidence Required',
            ClaimTimelineEventState.current,
            fallbackTime: claim.additionalEvidenceRequest?.requestedAt,
          ),
          _upcoming(ClaimTimelineStage.decision, 'Decision Pending'),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.approved:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _completedReview(claim),
          _item(
            claim,
            ClaimTimelineStage.decision,
            'Claim Approved',
            ClaimTimelineEventState.current,
            fallbackTime: claim.decision?.decidedAt,
          ),
          _upcoming(ClaimTimelineStage.payment, 'Payment Pending'),
        ];
      case ClaimStatus.rejected:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _completedReview(claim),
          _item(
            claim,
            ClaimTimelineStage.decision,
            'Claim Rejected',
            ClaimTimelineEventState.current,
            fallbackTime: claim.decision?.decidedAt,
          ),
        ];
      case ClaimStatus.paymentProcessing:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _completedReview(claim),
          _item(
            claim,
            ClaimTimelineStage.decision,
            'Claim Approved',
            ClaimTimelineEventState.completed,
            fallbackTime: claim.decision?.decidedAt,
          ),
          _item(
            claim,
            ClaimTimelineStage.payment,
            'Payment Processing',
            ClaimTimelineEventState.current,
          ),
          _upcoming(ClaimTimelineStage.settlement, 'Settlement Pending'),
        ];
      case ClaimStatus.settled:
        return <ClaimTimelineEvent>[
          _completedSubmission(claim),
          _completedAiAnalysis(claim),
          _completedReview(claim),
          _item(
            claim,
            ClaimTimelineStage.decision,
            'Claim Approved',
            ClaimTimelineEventState.completed,
            fallbackTime: claim.decision?.decidedAt,
          ),
          _item(
            claim,
            ClaimTimelineStage.payment,
            'Payment Completed',
            ClaimTimelineEventState.completed,
            fallbackTime: claim.payment?.paidAt,
          ),
          _item(
            claim,
            ClaimTimelineStage.settlement,
            'Claim Settled',
            ClaimTimelineEventState.current,
          ),
        ];
    }
  }

  static ClaimTimelineEvent _completedSubmission(InsuranceClaim claim) {
    return _item(
      claim,
      ClaimTimelineStage.submitted,
      'Claim Submitted',
      ClaimTimelineEventState.completed,
      fallbackTime: claim.submittedAt,
    );
  }

  static ClaimTimelineEvent _completedAiAnalysis(InsuranceClaim claim) {
    return _item(
      claim,
      ClaimTimelineStage.aiAnalysis,
      'AI Analysis Completed',
      ClaimTimelineEventState.completed,
      fallbackTime: claim.aiVerificationResult?.analysisTimestamp,
    );
  }

  static ClaimTimelineEvent _completedReview(InsuranceClaim claim) {
    return _item(
      claim,
      ClaimTimelineStage.manualReview,
      'Manual Review Completed',
      ClaimTimelineEventState.completed,
    );
  }

  static ClaimTimelineEvent _upcoming(ClaimTimelineStage stage, String title) {
    return ClaimTimelineEvent(
      stage: stage,
      title: title,
      state: ClaimTimelineEventState.upcoming,
    );
  }

  static ClaimTimelineEvent _item(
    InsuranceClaim claim,
    ClaimTimelineStage stage,
    String title,
    ClaimTimelineEventState state, {
    DateTime? fallbackTime,
  }) {
    DateTime? occurredAt;
    for (final ClaimTimelineEvent event in claim.history.reversed) {
      if (event.stage == stage) {
        occurredAt = event.occurredAt;
        break;
      }
    }

    return ClaimTimelineEvent(
      stage: stage,
      title: title,
      state: state,
      occurredAt: state == ClaimTimelineEventState.upcoming
          ? null
          : occurredAt ?? fallbackTime,
    );
  }
}
