import 'insurance_policy.dart';

class PolicyDetails {
  const PolicyDetails({
    required this.policy,
    required this.coverage,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.tertiaryLabel,
    required this.tertiaryValue,
    required this.isStoredOnBlockchain,
    required this.transactionHash,
  });

  final InsurancePolicy policy;

  final String coverage;

  final String primaryLabel;
  final String primaryValue;

  final String secondaryLabel;
  final String secondaryValue;

  final String tertiaryLabel;
  final String tertiaryValue;

  final bool isStoredOnBlockchain;

  final String transactionHash;
}