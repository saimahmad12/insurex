import '../../../policies/domain/entities/insurance_policy.dart';
import 'insurance_product.dart';

enum MarketplaceSort { none, premiumLowToHigh, coverageHighToLow }

class MarketplaceQuery {
  const MarketplaceQuery({
    this.searchText = '',
    this.category,
    this.sort = MarketplaceSort.none,
    this.favouritesOnly = false,
    this.maximumStartingPremium,
    this.minimumCoverage,
    this.durationMonths,
    this.providerName,
    this.page = 1,
    this.pageSize = 20,
  });

  final String searchText;
  final PolicyType? category;
  final MarketplaceSort sort;
  final bool favouritesOnly;
  final double? maximumStartingPremium;
  final double? minimumCoverage;
  final int? durationMonths;
  final String? providerName;
  final int page;
  final int pageSize;

  MarketplaceQuery copyWith({
    String? searchText,
    PolicyType? category,
    bool clearCategory = false,
    MarketplaceSort? sort,
    bool? favouritesOnly,
    double? maximumStartingPremium,
    bool clearMaximumStartingPremium = false,
    double? minimumCoverage,
    bool clearMinimumCoverage = false,
    int? durationMonths,
    bool clearDuration = false,
    String? providerName,
    bool clearProvider = false,
    int? page,
    int? pageSize,
  }) {
    return MarketplaceQuery(
      searchText: searchText ?? this.searchText,
      category: clearCategory ? null : category ?? this.category,
      sort: sort ?? this.sort,
      favouritesOnly: favouritesOnly ?? this.favouritesOnly,
      maximumStartingPremium: clearMaximumStartingPremium
          ? null
          : maximumStartingPremium ?? this.maximumStartingPremium,
      minimumCoverage: clearMinimumCoverage
          ? null
          : minimumCoverage ?? this.minimumCoverage,
      durationMonths: clearDuration
          ? null
          : durationMonths ?? this.durationMonths,
      providerName: clearProvider ? null : providerName ?? this.providerName,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class MarketplacePageResult {
  const MarketplacePageResult({
    required this.products,
    required this.page,
    required this.hasMore,
  });

  final List<InsuranceProduct> products;
  final int page;
  final bool hasMore;
}
