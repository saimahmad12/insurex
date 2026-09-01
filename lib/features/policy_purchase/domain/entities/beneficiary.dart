class PolicyBeneficiary {
  const PolicyBeneficiary({
    required this.legalName,
    required this.relationship,
    required this.dateOfBirth,
    required this.contactDetails,
    required this.allocationPercentage,
  });

  final String legalName;
  final String relationship;
  final DateTime dateOfBirth;
  final String contactDetails;
  final double allocationPercentage;
}
