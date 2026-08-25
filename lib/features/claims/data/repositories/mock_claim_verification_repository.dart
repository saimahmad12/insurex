import '../../domain/entities/ai_verification_result.dart';
import '../../domain/entities/claim_image.dart';
import '../../domain/repositories/claim_verification_repository.dart';

class MockClaimVerificationRepository implements ClaimVerificationRepository {
  const MockClaimVerificationRepository({
    this.delay = const Duration(milliseconds: 500),
    this.shouldFail = false,
    this.result,
  });

  final Duration delay;
  final bool shouldFail;
  final AiVerificationResult? result;

  @override
  Future<AiVerificationResult> verifyImages(List<ClaimImage> images) async {
    await Future<void>.delayed(delay);
    if (shouldFail) {
      throw StateError('Image verification failed.');
    }

    return result ??
        AiVerificationResult(
          classification: EvidenceClassification.authentic,
          fraudRiskScore: 14,
          confidenceScore: 94,
          detectedIssues: const <String>[],
          requiresManualReview: false,
          modelVersion: 'insurex-evidence-mock-1.0',
          analysisTimestamp: DateTime.now(),
        );
  }
}
