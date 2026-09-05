enum SellerRegistrationStatus {
  draft,
  submitting,
  pendingApproval,
  approved,
  rejected,
  suspended,
  technicalFailure,
}

enum InsuranceCategory { health, life, vehicle, property, travel, agriculture }

enum RepresentativeDesignation {
  chiefExecutiveOfficer,
  managingDirector,
  director,
  authorizedOfficer,
  complianceOfficer,
}

class SellerRegistrationRequest {
  SellerRegistrationRequest({
    required this.registeredCompanyName,
    required this.businessEmail,
    required this.businessPhoneNumber,
    required this.companyRegistrationNumber,
    required this.insuranceLicenseNumber,
    required this.officeAddress,
    required this.authorizedRepresentativeName,
    required this.authorizedRepresentativeDesignation,
    required Set<InsuranceCategory> supportedCategories,
    required this.password,
    required this.acceptedTerms,
    required this.confirmedDeclarations,
  }) : supportedCategories = Set<InsuranceCategory>.unmodifiable(
         supportedCategories,
       );

  final String registeredCompanyName;
  final String businessEmail;
  final String businessPhoneNumber;
  final String companyRegistrationNumber;
  final String insuranceLicenseNumber;
  final String officeAddress;
  final String authorizedRepresentativeName;
  final RepresentativeDesignation authorizedRepresentativeDesignation;
  final Set<InsuranceCategory> supportedCategories;
  final String password;
  final bool acceptedTerms;
  final bool confirmedDeclarations;
}

class SellerRegistrationResult {
  const SellerRegistrationResult({required this.status, this.referenceNumber});

  final SellerRegistrationStatus status;
  final String? referenceNumber;
}
