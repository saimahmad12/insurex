enum ClaimDecisionOutcome { approved, rejected }

class ClaimDecision {
  const ClaimDecision({
    required this.outcome,
    required this.decidedAt,
    required this.message,
    this.approvedAmount,
    this.reason,
  });

  final ClaimDecisionOutcome outcome;
  final DateTime decidedAt;
  final String message;
  final double? approvedAmount;
  final String? reason;
}
