enum EvidenceClassification {
  authentic,
  manipulated,
  aiGenerated,
  inconclusive,
}

enum AiAnalysisStatus { pending, analysing, completed, failed }

class AiVerificationResult {
  const AiVerificationResult({
    required this.classification,
    required this.fraudRiskScore,
    required this.confidenceScore,
    required this.detectedIssues,
    required this.requiresManualReview,
    required this.modelVersion,
    required this.analysisTimestamp,
    this.analysedImageCount = 0,
  }) : assert(fraudRiskScore >= 0 && fraudRiskScore <= 100),
       assert(confidenceScore >= 0 && confidenceScore <= 100);

  final EvidenceClassification classification;
  final int fraudRiskScore;
  final int confidenceScore;
  final List<String> detectedIssues;
  final bool requiresManualReview;
  final String modelVersion;
  final DateTime analysisTimestamp;
  final int analysedImageCount;
}
