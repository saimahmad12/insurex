import '../../domain/entities/beneficiary.dart';

abstract final class BeneficiaryValidator {
  static Map<String, String> validate(
    List<PolicyBeneficiary> beneficiaries, {
    DateTime? today,
  }) {
    final Map<String, String> errors = <String, String>{};
    if (beneficiaries.isEmpty) {
      errors['beneficiaries'] = 'Add at least one beneficiary.';
      return errors;
    }
    final DateTime reference = today ?? DateTime.now();
    for (final PolicyBeneficiary beneficiary in beneficiaries) {
      if (beneficiary.legalName.trim().isEmpty ||
          beneficiary.relationship.trim().isEmpty ||
          beneficiary.contactDetails.trim().isEmpty ||
          beneficiary.dateOfBirth.isAfter(reference) ||
          !beneficiary.allocationPercentage.isFinite ||
          beneficiary.allocationPercentage <= 0) {
        errors['beneficiaries'] =
            'Complete valid details for every beneficiary.';
        break;
      }
    }
    final double allocation = beneficiaries.fold<double>(
      0,
      (double total, PolicyBeneficiary item) =>
          total + item.allocationPercentage,
    );
    if (!allocation.isFinite || (allocation - 100).abs() > 0.001) {
      errors['allocation'] = 'Beneficiary allocations must total exactly 100%.';
    }
    return errors;
  }
}
