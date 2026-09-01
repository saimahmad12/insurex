enum PolicyType { vehicle, health, travel, life, property }

enum PolicyStatus { active, pending, expired }

class InsurancePolicy {
  const InsurancePolicy({
    required this.id,
    required this.policyNumber,
    required this.title,
    required this.type,
    required this.validTill,
    required this.premium,
    required this.status,
    this.providerName,
    this.coverageAmount,
    this.startDate,
    this.paymentReference,
    this.documentReference,
    this.blockchainRecordStatus,
  });

  final String id;
  final String policyNumber;
  final String title;
  final PolicyType type;
  final DateTime validTill;
  final double premium;
  final PolicyStatus status;
  final String? providerName;
  final double? coverageAmount;
  final DateTime? startDate;
  final String? paymentReference;
  final String? documentReference;
  final String? blockchainRecordStatus;
}
