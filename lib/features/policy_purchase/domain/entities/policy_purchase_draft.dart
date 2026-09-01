import 'beneficiary.dart';
import 'policy_application_details.dart';
import 'policy_configuration.dart';

class PolicyPurchaseDraft {
  const PolicyPurchaseDraft({
    required this.id,
    required this.productId,
    required this.configuration,
    required this.updatedAt,
    this.applicationDetails,
    this.beneficiaries = const <PolicyBeneficiary>[],
  });

  final String id;
  final String productId;
  final PolicyConfiguration configuration;
  final PolicyApplicationDetails? applicationDetails;
  final List<PolicyBeneficiary> beneficiaries;
  final DateTime updatedAt;

  PolicyPurchaseDraft copyWith({
    PolicyConfiguration? configuration,
    PolicyApplicationDetails? applicationDetails,
    List<PolicyBeneficiary>? beneficiaries,
    DateTime? updatedAt,
  }) {
    return PolicyPurchaseDraft(
      id: id,
      productId: productId,
      configuration: configuration ?? this.configuration,
      applicationDetails: applicationDetails ?? this.applicationDetails,
      beneficiaries: List<PolicyBeneficiary>.unmodifiable(
        beneficiaries ?? this.beneficiaries,
      ),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
