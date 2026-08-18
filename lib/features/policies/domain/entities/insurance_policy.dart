enum PolicyType {
  vehicle,
  health,
  travel,
}

enum PolicyStatus {
  active,
  expired,
}

class InsurancePolicy {
  const InsurancePolicy({
    required this.id,
    required this.policyNumber,
    required this.title,
    required this.type,
    required this.validTill,
    required this.premium,
    required this.status,
  });

  final String id;
  final String policyNumber;
  final String title;
  final PolicyType type;
  final DateTime validTill;
  final double premium;
  final PolicyStatus status;
}