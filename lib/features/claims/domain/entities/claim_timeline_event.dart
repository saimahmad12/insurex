enum ClaimTimelineStage {
  draft,
  submitted,
  aiAnalysis,
  manualReview,
  additionalEvidence,
  decision,
  payment,
  settlement,
}

enum ClaimTimelineEventState { completed, current, upcoming }

class ClaimTimelineEvent {
  const ClaimTimelineEvent({
    required this.stage,
    required this.title,
    required this.state,
    this.occurredAt,
  });

  final ClaimTimelineStage stage;
  final String title;
  final ClaimTimelineEventState state;
  final DateTime? occurredAt;
}
