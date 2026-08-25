enum ClaimPolicyType { vehicle, health, travel }

enum ClaimPolicyStatus { active, inactive, expired }

class ClaimPolicy {
  const ClaimPolicy({
    required this.id,
    required this.name,
    required this.policyNumber,
    required this.type,
    required this.coverageType,
    required this.expiresAt,
    required this.coverageLimit,
    required this.status,
  });

  final String id;
  final String name;
  final String policyNumber;
  final ClaimPolicyType type;
  final String coverageType;
  final DateTime expiresAt;
  final double coverageLimit;
  final ClaimPolicyStatus status;

  bool isEligibleAt(DateTime date) {
    final DateTime today = DateTime(date.year, date.month, date.day);
    final DateTime expiry = DateTime(
      expiresAt.year,
      expiresAt.month,
      expiresAt.day,
    );

    return status == ClaimPolicyStatus.active && !expiry.isBefore(today);
  }
}
