import '../../domain/entities/policy_application_details.dart';
import '../../domain/entities/policy_configuration.dart';

abstract final class PolicyPurchaseValidator {
  static Map<String, String> validateConfiguration(
    PolicyConfiguration configuration, {
    required double minimumCoverage,
    required double maximumCoverage,
  }) {
    final Map<String, String> errors = <String, String>{};
    if (configuration.coverageAmount < minimumCoverage ||
        configuration.coverageAmount > maximumCoverage) {
      errors['coverageAmount'] = 'Select a coverage amount within plan limits.';
    }
    if (configuration.durationMonths <= 0) {
      errors['durationMonths'] = 'Select a policy duration.';
    }
    if (configuration.deductible < 0) {
      errors['deductible'] = 'Deductible cannot be negative.';
    }
    if (configuration.insuredPeople < 1) {
      errors['insuredPeople'] = 'At least one insured person is required.';
    }
    return errors;
  }

  static Map<String, String> validateApplication(
    PolicyApplicationDetails details, {
    DateTime? today,
  }) {
    final DateTime reference = today ?? DateTime.now();
    final Map<String, String> errors = <String, String>{};
    switch (details) {
      case VehiclePolicyApplication value:
        _required(errors, 'registrationNumber', value.registrationNumber);
        _required(errors, 'make', value.make);
        _required(errors, 'model', value.model);
        _required(errors, 'chassisNumber', value.chassisNumber);
        _required(errors, 'usageType', value.usageType);
        _required(
          errors,
          'existingDamageDeclaration',
          value.existingDamageDeclaration,
        );
        if (value.manufacturingYear < 1980 ||
            value.manufacturingYear > reference.year) {
          errors['manufacturingYear'] = 'Enter a valid manufacturing year.';
        }
        if (value.vehicleValue <= 0) {
          errors['vehicleValue'] = 'Enter a valid vehicle value.';
        }
      case HealthPolicyApplication value:
        if (value.members.isEmpty) {
          errors['members'] = 'Add at least one insured member.';
        }
        for (final HealthInsuredMember member in value.members) {
          if (member.legalName.trim().isEmpty ||
              member.relationship.trim().isEmpty ||
              member.dateOfBirth.isAfter(reference)) {
            errors['members'] = 'Complete valid details for every member.';
            break;
          }
        }
        _required(errors, 'coverageRequirements', value.coverageRequirements);
        _required(errors, 'healthDeclaration', value.healthDeclaration);
      case TravelPolicyApplication value:
        _required(errors, 'destination', value.destination);
        _required(errors, 'tripPurpose', value.tripPurpose);
        _required(errors, 'coverageRegion', value.coverageRegion);
        if (value.departureDate.isBefore(
          DateTime(reference.year, reference.month, reference.day),
        )) {
          errors['departureDate'] = 'Departure date cannot be in the past.';
        }
        if (!value.returnDate.isAfter(value.departureDate)) {
          errors['returnDate'] = 'Return date must be after departure.';
        }
        if (value.travellers.isEmpty) {
          errors['travellers'] = 'Add at least one traveller.';
        }
      case LifePolicyApplication value:
        if (value.coverageAmount <= 0) {
          errors['coverageAmount'] = 'Enter a valid life coverage amount.';
        }
        _required(errors, 'occupation', value.occupation);
      case PropertyPolicyApplication value:
        _required(errors, 'propertyType', value.propertyType);
        _required(errors, 'address', value.address);
        _required(errors, 'ownershipStatus', value.ownershipStatus);
        _required(errors, 'coverageType', value.coverageType);
        if (value.estimatedValue <= 0) {
          errors['estimatedValue'] = 'Enter a valid property value.';
        }
    }
    return errors;
  }

  static void _required(Map<String, String> errors, String key, String value) {
    if (value.trim().isEmpty) {
      errors[key] = 'Complete all required information.';
    }
  }
}
