class AdditionalEvidenceRequest {
  const AdditionalEvidenceRequest({
    required this.title,
    required this.reason,
    required this.requestedAt,
    this.submissionDeadline,
  });

  final String title;
  final String reason;
  final DateTime requestedAt;
  final DateTime? submissionDeadline;
}
