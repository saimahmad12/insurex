import '../../../policies/domain/entities/insurance_policy.dart';
import '../../domain/entities/insurance_product.dart';
import '../../domain/entities/marketplace_query.dart';
import '../../domain/repositories/insurance_marketplace_repository.dart';

class MockInsuranceMarketplaceRepository
    implements InsuranceMarketplaceRepository {
  MockInsuranceMarketplaceRepository({
    this.delay = const Duration(milliseconds: 350),
    this.failLoading = false,
    List<InsuranceProduct>? products,
  }) : _products = products ?? sampleProducts;

  final Duration delay;
  final bool failLoading;
  final List<InsuranceProduct> _products;
  int productsCallCount = 0;
  int productDetailsCallCount = 0;

  static final List<InsuranceProduct> sampleProducts = <InsuranceProduct>[
    _product(
      id: 'vehicle-comprehensive-01',
      name: 'Drive Secure Comprehensive',
      providerId: 'provider-pakshield',
      providerName: 'PakShield Insurance',
      category: PolicyType.vehicle,
      startingPremium: 24500,
      minimumCoverage: 500000,
      maximumCoverage: 10000000,
      benefits: <String>[
        'Accidental damage',
        'Theft protection',
        'Roadside assistance',
      ],
      requiredInformation: <String>[
        'Vehicle registration and chassis details',
        'Vehicle value and existing damage declaration',
      ],
    ),
    _product(
      id: 'health-family-01',
      name: 'Family Health Plus',
      providerId: 'provider-sehat',
      providerName: 'Sehat Assurance',
      category: PolicyType.health,
      startingPremium: 18500,
      minimumCoverage: 300000,
      maximumCoverage: 5000000,
      benefits: <String>[
        'Hospitalisation cover',
        'Emergency treatment',
        'Family coverage options',
      ],
      requiredInformation: <String>[
        'Insured-member details',
        'Relevant health declarations',
      ],
      requiresProviderReview: true,
    ),
    _product(
      id: 'travel-worldwide-01',
      name: 'Worldwide Travel Protect',
      providerId: 'provider-safarpak',
      providerName: 'SafarPak Takaful',
      category: PolicyType.travel,
      startingPremium: 4200,
      minimumCoverage: 250000,
      maximumCoverage: 3000000,
      benefits: <String>[
        'Medical emergencies',
        'Trip interruption',
        'Baggage delay support',
      ],
      requiredInformation: <String>[
        'Travel dates and destination',
        'Traveller details and trip purpose',
      ],
    ),
    _product(
      id: 'life-protection-01',
      name: 'Life Protection Plan',
      providerId: 'provider-amanlife',
      providerName: 'Aman Life Assurance',
      category: PolicyType.life,
      startingPremium: 12500,
      minimumCoverage: 1000000,
      maximumCoverage: 25000000,
      benefits: <String>[
        'Life coverage',
        'Flexible beneficiary allocation',
        'Annual payment options',
      ],
      requiredInformation: <String>[
        'Occupation and coverage need',
        'Beneficiary details totalling 100%',
      ],
      requiresBeneficiaries: true,
      requiresProviderReview: true,
    ),
    _product(
      id: 'property-home-01',
      name: 'Home & Property Shield',
      providerId: 'provider-mehfooz',
      providerName: 'Mehfooz General Insurance',
      category: PolicyType.property,
      startingPremium: 16000,
      minimumCoverage: 1000000,
      maximumCoverage: 50000000,
      benefits: <String>[
        'Fire and natural hazards',
        'Contents protection',
        'Temporary accommodation support',
      ],
      requiredInformation: <String>[
        'Property address and ownership status',
        'Estimated property value and coverage type',
      ],
      requiresProviderReview: true,
    ),
  ];

  @override
  Future<MarketplacePageResult> getProducts(MarketplaceQuery query) async {
    productsCallCount++;
    await _wait();
    if (failLoading) {
      throw StateError('Marketplace products are unavailable.');
    }
    Iterable<InsuranceProduct> filtered = _products;
    final String search = query.searchText.trim().toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered.where(
        (InsuranceProduct product) =>
            product.name.toLowerCase().contains(search) ||
            product.providerName.toLowerCase().contains(search) ||
            product.category.name.toLowerCase().contains(search),
      );
    }
    if (query.category != null) {
      filtered = filtered.where(
        (InsuranceProduct product) => product.category == query.category,
      );
    }
    if (query.maximumStartingPremium != null) {
      filtered = filtered.where(
        (InsuranceProduct product) =>
            product.startingPremium <= query.maximumStartingPremium!,
      );
    }
    if (query.minimumCoverage != null) {
      filtered = filtered.where(
        (InsuranceProduct product) =>
            product.maximumCoverage >= query.minimumCoverage!,
      );
    }
    if (query.durationMonths != null) {
      filtered = filtered.where(
        (InsuranceProduct product) =>
            product.availableDurationsMonths.contains(query.durationMonths),
      );
    }
    if (query.providerName != null) {
      filtered = filtered.where(
        (InsuranceProduct product) =>
            product.providerName == query.providerName,
      );
    }
    final List<InsuranceProduct> sorted = filtered.toList();
    switch (query.sort) {
      case MarketplaceSort.none:
        break;
      case MarketplaceSort.premiumLowToHigh:
        sorted.sort(
          (InsuranceProduct first, InsuranceProduct second) =>
              first.startingPremium.compareTo(second.startingPremium),
        );
      case MarketplaceSort.coverageHighToLow:
        sorted.sort(
          (InsuranceProduct first, InsuranceProduct second) =>
              second.maximumCoverage.compareTo(first.maximumCoverage),
        );
    }
    final int start = (query.page - 1) * query.pageSize;
    if (start >= sorted.length) {
      return MarketplacePageResult(
        products: const <InsuranceProduct>[],
        page: query.page,
        hasMore: false,
      );
    }
    final int end = (start + query.pageSize).clamp(0, sorted.length);
    return MarketplacePageResult(
      products: List<InsuranceProduct>.unmodifiable(sorted.sublist(start, end)),
      page: query.page,
      hasMore: end < sorted.length,
    );
  }

  @override
  Future<InsuranceProduct?> getProductById(String productId) async {
    productDetailsCallCount++;
    await _wait();
    if (failLoading) {
      throw StateError('Product details are unavailable.');
    }
    for (final InsuranceProduct product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  static InsuranceProduct _product({
    required String id,
    required String name,
    required String providerId,
    required String providerName,
    required PolicyType category,
    required double startingPremium,
    required double minimumCoverage,
    required double maximumCoverage,
    required List<String> benefits,
    required List<String> requiredInformation,
    bool requiresBeneficiaries = false,
    bool requiresProviderReview = false,
  }) {
    return InsuranceProduct(
      id: id,
      name: name,
      providerId: providerId,
      providerName: providerName,
      providerVerificationStatus: ProviderVerificationStatus.verified,
      category: category,
      description:
          'Flexible ${category.name} protection published by a verified insurance provider.',
      startingPremium: startingPremium,
      minimumCoverage: minimumCoverage,
      maximumCoverage: maximumCoverage,
      availableDurationsMonths: const <int>[6, 12, 24],
      availableDeductibles: const <double>[0, 10000, 25000],
      availableAddOns: const <String>[
        'Emergency assistance',
        'Enhanced protection',
      ],
      paymentFrequencies: const <PremiumFrequency>[
        PremiumFrequency.monthly,
        PremiumFrequency.quarterly,
        PremiumFrequency.annually,
      ],
      keyBenefits: benefits,
      coveredEvents: benefits,
      exclusions: const <String>[
        'Intentional loss or misrepresentation',
        'Events excluded by the final provider wording',
      ],
      eligibilitySummary: 'Adults living in supported locations may apply.',
      eligibilityRequirements: const <String>[
        'Verified identity before application submission',
        'Age and location must meet provider rules',
      ],
      cancellationTerms:
          'Cancellation is subject to the final provider policy wording.',
      requiredInformation: requiredInformation,
      termsSummary:
          'Final policy wording, exclusions, and terms are provided before submission.',
      waitingPeriod: category == PolicyType.health
          ? 'Provider-defined waiting periods may apply.'
          : 'No standard waiting period; provider rules apply.',
      claimLimits: 'Limits and sub-limits are shown in the final quotation.',
      minimumAge: 18,
      maximumAge: category == PolicyType.life ? 60 : 70,
      supportedLocations: const <String>[
        'Pakistan',
        'Islamabad',
        'Karachi',
        'Lahore',
      ],
      requiresBeneficiaries: requiresBeneficiaries,
      requiresProviderReview: requiresProviderReview,
      isAvailable: true,
    );
  }
}
