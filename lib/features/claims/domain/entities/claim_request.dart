import 'ai_verification_result.dart';
import 'claim_image.dart';
import 'claim_policy.dart';
import 'incident_details.dart';

class ClaimRequest {
  const ClaimRequest({
    required this.policy,
    required this.incidentDetails,
    required this.images,
    required this.verificationResult,
    required this.declarationAccepted,
    required this.aiAnalysisConsentAccepted,
  });

  final ClaimPolicy policy;
  final IncidentDetails incidentDetails;
  final List<ClaimImage> images;
  final AiVerificationResult verificationResult;
  final bool declarationAccepted;
  final bool aiAnalysisConsentAccepted;
}
