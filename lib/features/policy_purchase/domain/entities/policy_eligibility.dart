enum EligibilityDecision { eligible, additionalInformationRequired, ineligible }

class PolicyEligibilityRequest {
  const PolicyEligibilityRequest({
    required this.productId,
    required this.identityVerified,
    required this.age,
    required this.minimumAge,
    required this.maximumAge,
    required this.location,
    required this.locationSupported,
    required this.productAvailable,
    required this.hasRestrictedExistingPolicy,
    required this.hasRequiredInformation,
  });

  final String productId;
  final bool identityVerified;
  final int age;
  final int minimumAge;
  final int maximumAge;
  final String location;
  final bool locationSupported;
  final bool productAvailable;
  final bool hasRestrictedExistingPolicy;
  final bool hasRequiredInformation;
}

class PolicyEligibilityResult {
  const PolicyEligibilityResult({
    required this.decision,
    this.reason,
    this.requiredInformation = const <String>[],
  });

  final EligibilityDecision decision;
  final String? reason;
  final List<String> requiredInformation;
}
