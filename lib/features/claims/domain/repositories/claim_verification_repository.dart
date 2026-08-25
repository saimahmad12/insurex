import '../entities/ai_verification_result.dart';
import '../entities/claim_image.dart';

abstract interface class ClaimVerificationRepository {
  Future<AiVerificationResult> verifyImages(List<ClaimImage> images);
}
