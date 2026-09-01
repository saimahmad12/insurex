import '../../../insurance_marketplace/domain/entities/insurance_product.dart';
import 'beneficiary.dart';
import 'policy_application_details.dart';
import 'policy_configuration.dart';
import 'policy_quote.dart';

enum PolicyApplicationStatus {
  draft,
  identityVerificationRequired,
  identityVerificationPending,
  readyToSubmit,
  submitted,
  underReview,
  additionalInformationRequired,
  approved,
  paymentPending,
  issued,
  rejected,
  cancelled,
}

class PolicyApplicationSubmissionRequest {
  const PolicyApplicationSubmissionRequest({
    required this.product,
    required this.configuration,
    required this.details,
    required this.beneficiaries,
    required this.quote,
    required this.applicantId,
    required this.applicantName,
    required this.maskedIdentityNumber,
  });

  final InsuranceProduct product;
  final PolicyConfiguration configuration;
  final PolicyApplicationDetails details;
  final List<PolicyBeneficiary> beneficiaries;
  final PolicyQuote quote;
  final String applicantId;
  final String applicantName;
  final String maskedIdentityNumber;
}

class PolicyApplication {
  const PolicyApplication({
    required this.id,
    required this.request,
    required this.status,
    required this.submittedAt,
    this.generalReason,
  });

  final String id;
  final PolicyApplicationSubmissionRequest request;
  final PolicyApplicationStatus status;
  final DateTime submittedAt;
  final String? generalReason;

  PolicyApplication copyWith({
    PolicyApplicationStatus? status,
    String? generalReason,
  }) {
    return PolicyApplication(
      id: id,
      request: request,
      status: status ?? this.status,
      submittedAt: submittedAt,
      generalReason: generalReason ?? this.generalReason,
    );
  }
}
