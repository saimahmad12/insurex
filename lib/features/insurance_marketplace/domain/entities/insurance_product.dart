import '../../../policies/domain/entities/insurance_policy.dart';

enum ProviderVerificationStatus { verified }

enum PremiumFrequency { monthly, quarterly, annually, single }

class InsuranceProduct {
  const InsuranceProduct({
    required this.id,
    required this.name,
    required this.providerId,
    required this.providerName,
    required this.providerVerificationStatus,
    required this.category,
    required this.description,
    required this.startingPremium,
    required this.minimumCoverage,
    required this.maximumCoverage,
    required this.availableDurationsMonths,
    required this.availableDeductibles,
    required this.availableAddOns,
    required this.paymentFrequencies,
    required this.keyBenefits,
    required this.coveredEvents,
    required this.exclusions,
    required this.eligibilitySummary,
    required this.eligibilityRequirements,
    required this.cancellationTerms,
    required this.requiredInformation,
    required this.termsSummary,
    required this.waitingPeriod,
    required this.claimLimits,
    required this.minimumAge,
    required this.maximumAge,
    required this.supportedLocations,
    required this.requiresBeneficiaries,
    required this.requiresProviderReview,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String providerId;
  final String providerName;
  final ProviderVerificationStatus providerVerificationStatus;
  final PolicyType category;
  final String description;
  final double startingPremium;
  final double minimumCoverage;
  final double maximumCoverage;
  final List<int> availableDurationsMonths;
  final List<double> availableDeductibles;
  final List<String> availableAddOns;
  final List<PremiumFrequency> paymentFrequencies;
  final List<String> keyBenefits;
  final List<String> coveredEvents;
  final List<String> exclusions;
  final String eligibilitySummary;
  final List<String> eligibilityRequirements;
  final String cancellationTerms;
  final List<String> requiredInformation;
  final String termsSummary;
  final String waitingPeriod;
  final String claimLimits;
  final int minimumAge;
  final int maximumAge;
  final List<String> supportedLocations;
  final bool requiresBeneficiaries;
  final bool requiresProviderReview;
  final bool isAvailable;

  bool get providerIsVerified =>
      providerVerificationStatus == ProviderVerificationStatus.verified;
}
