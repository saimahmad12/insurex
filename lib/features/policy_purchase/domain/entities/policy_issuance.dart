import '../../../policies/domain/entities/insurance_policy.dart';
import 'policy_application.dart';
import 'policy_quote.dart';
import 'premium_payment.dart';

class PolicyIssuanceRequest {
  const PolicyIssuanceRequest({
    required this.application,
    required this.quote,
    required this.payment,
  });

  final PolicyApplication application;
  final PolicyQuote quote;
  final PremiumPayment payment;
}

class PolicyIssuanceResult {
  const PolicyIssuanceResult({
    required this.policy,
    required this.policyDocumentReference,
    required this.blockchainRecordStatus,
  });

  final InsurancePolicy policy;
  final String policyDocumentReference;
  final String blockchainRecordStatus;
}
