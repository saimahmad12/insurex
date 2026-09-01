import '../../../policies/domain/entities/insurance_policy.dart';

sealed class PolicyApplicationDetails {
  const PolicyApplicationDetails();

  PolicyType get category;
  Map<String, String> get summary;
}

class VehiclePolicyApplication extends PolicyApplicationDetails {
  const VehiclePolicyApplication({
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.manufacturingYear,
    required this.vehicleValue,
    required this.chassisNumber,
    required this.usageType,
    required this.existingDamageDeclaration,
  });

  final String registrationNumber;
  final String make;
  final String model;
  final int manufacturingYear;
  final double vehicleValue;
  final String chassisNumber;
  final String usageType;
  final String existingDamageDeclaration;

  @override
  PolicyType get category => PolicyType.vehicle;

  @override
  Map<String, String> get summary => <String, String>{
    'Vehicle': '$make $model $manufacturingYear',
    'Registration': registrationNumber,
    'Usage': usageType,
  };
}

class HealthInsuredMember {
  const HealthInsuredMember({
    required this.legalName,
    required this.relationship,
    required this.dateOfBirth,
  });

  final String legalName;
  final String relationship;
  final DateTime dateOfBirth;
}

class HealthPolicyApplication extends PolicyApplicationDetails {
  const HealthPolicyApplication({
    required this.members,
    required this.coverageRequirements,
    required this.healthDeclaration,
  });

  final List<HealthInsuredMember> members;
  final String coverageRequirements;
  final String healthDeclaration;

  @override
  PolicyType get category => PolicyType.health;

  @override
  Map<String, String> get summary => <String, String>{
    'Insured members': '${members.length}',
    'Coverage requirements': coverageRequirements,
  };
}

class TravelTraveller {
  const TravelTraveller({required this.legalName, required this.dateOfBirth});

  final String legalName;
  final DateTime dateOfBirth;
}

class TravelPolicyApplication extends PolicyApplicationDetails {
  const TravelPolicyApplication({
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.travellers,
    required this.tripPurpose,
    required this.coverageRegion,
  });

  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final List<TravelTraveller> travellers;
  final String tripPurpose;
  final String coverageRegion;

  @override
  PolicyType get category => PolicyType.travel;

  @override
  Map<String, String> get summary => <String, String>{
    'Destination': destination,
    'Travellers': '${travellers.length}',
    'Purpose': tripPurpose,
  };
}

class LifePolicyApplication extends PolicyApplicationDetails {
  const LifePolicyApplication({
    required this.coverageAmount,
    required this.occupation,
  });

  final double coverageAmount;
  final String occupation;

  @override
  PolicyType get category => PolicyType.life;

  @override
  Map<String, String> get summary => <String, String>{
    'Occupation': occupation,
    'Coverage amount': coverageAmount.toStringAsFixed(0),
  };
}

class PropertyPolicyApplication extends PolicyApplicationDetails {
  const PropertyPolicyApplication({
    required this.propertyType,
    required this.address,
    required this.estimatedValue,
    required this.ownershipStatus,
    required this.coverageType,
  });

  final String propertyType;
  final String address;
  final double estimatedValue;
  final String ownershipStatus;
  final String coverageType;

  @override
  PolicyType get category => PolicyType.property;

  @override
  Map<String, String> get summary => <String, String>{
    'Property': propertyType,
    'Address': address,
    'Coverage type': coverageType,
  };
}
