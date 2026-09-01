import 'package:flutter/foundation.dart';

import '../../../policies/domain/entities/insurance_policy.dart';
import '../../domain/entities/insurance_product.dart';
import '../../domain/entities/marketplace_query.dart';
import '../../domain/repositories/insurance_marketplace_repository.dart';

enum MarketplaceLoadStatus { initial, loading, success, empty, failure }

enum MarketplaceRefreshStatus { idle, refreshing, failure }

enum MarketplacePaginationStatus { idle, loading, failure }

class InsuranceMarketplaceController extends ChangeNotifier {
  InsuranceMarketplaceController({
    required InsuranceMarketplaceRepository repository,
  }) : _repository = repository;

  final InsuranceMarketplaceRepository _repository;
  MarketplaceLoadStatus _loadStatus = MarketplaceLoadStatus.initial;
  MarketplaceRefreshStatus _refreshStatus = MarketplaceRefreshStatus.idle;
  MarketplacePaginationStatus _paginationStatus =
      MarketplacePaginationStatus.idle;
  MarketplaceQuery _query = const MarketplaceQuery();
  List<InsuranceProduct> _products = const <InsuranceProduct>[];
  final Set<String> _favouriteIds = <String>{};
  final Set<String> _comparisonIds = <String>{};
  final Set<String> _availableProviders = <String>{};
  String? _errorMessage;
  bool _hasMore = false;
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _disposed = false;

  MarketplaceLoadStatus get loadStatus => _loadStatus;
  MarketplaceRefreshStatus get refreshStatus => _refreshStatus;
  MarketplacePaginationStatus get paginationStatus => _paginationStatus;
  MarketplaceQuery get query => _query;
  List<InsuranceProduct> get products => _query.favouritesOnly
      ? List<InsuranceProduct>.unmodifiable(
          _products.where(
            (InsuranceProduct product) => _favouriteIds.contains(product.id),
          ),
        )
      : _products;
  List<InsuranceProduct> get comparisonProducts =>
      List<InsuranceProduct>.unmodifiable(
        _products.where(
          (InsuranceProduct product) => _comparisonIds.contains(product.id),
        ),
      );
  Set<String> get favouriteIds => Set<String>.unmodifiable(_favouriteIds);
  Set<String> get comparisonIds => Set<String>.unmodifiable(_comparisonIds);
  List<String> get availableProviders => _availableProviders.toList()..sort();
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isInitialLoading =>
      _loadStatus == MarketplaceLoadStatus.loading && _products.isEmpty;
  bool get isRefreshing =>
      _refreshStatus == MarketplaceRefreshStatus.refreshing;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadInitial();
  }

  Future<void> retry() => _loadInitial();

  Future<void> refresh() async {
    if (_loadInProgress) {
      return;
    }
    _refreshStatus = MarketplaceRefreshStatus.refreshing;
    _notify();
    try {
      await _replaceProducts(_query.copyWith(page: 1));
      _refreshStatus = MarketplaceRefreshStatus.idle;
    } catch (_) {
      _refreshStatus = MarketplaceRefreshStatus.failure;
      _errorMessage =
          'Unable to refresh products. Existing results are still shown.';
    } finally {
      _notify();
    }
  }

  Future<void> updateSearch(String value) {
    _query = _query.copyWith(searchText: value, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> selectCategory(PolicyType? category) {
    _query = category == null
        ? _query.copyWith(clearCategory: true, page: 1)
        : _query.copyWith(category: category, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> selectSort(MarketplaceSort sort) {
    if (_query.sort == sort) {
      return Future<void>.value();
    }
    _query = _query.copyWith(sort: sort, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> setMaximumPremium(double? value) {
    _query = value == null
        ? _query.copyWith(clearMaximumStartingPremium: true, page: 1)
        : _query.copyWith(maximumStartingPremium: value, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> setMinimumCoverage(double? value) {
    _query = value == null
        ? _query.copyWith(clearMinimumCoverage: true, page: 1)
        : _query.copyWith(minimumCoverage: value, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> setDuration(int? value) {
    _query = value == null
        ? _query.copyWith(clearDuration: true, page: 1)
        : _query.copyWith(durationMonths: value, page: 1);
    return _loadForChangedQuery();
  }

  Future<void> setProvider(String? value) {
    _query = value == null
        ? _query.copyWith(clearProvider: true, page: 1)
        : _query.copyWith(providerName: value, page: 1);
    return _loadForChangedQuery();
  }

  void toggleFavouritesOnly() {
    _query = _query.copyWith(favouritesOnly: !_query.favouritesOnly);
    _applyLoadedState();
    _notify();
  }

  void toggleFavourite(String productId) {
    if (!_favouriteIds.add(productId)) {
      _favouriteIds.remove(productId);
    }
    _applyLoadedState();
    _notify();
  }

  bool toggleComparison(String productId) {
    if (_comparisonIds.remove(productId)) {
      _notify();
      return true;
    }
    if (_comparisonIds.length >= 3) {
      _errorMessage = 'Compare up to three insurance products at a time.';
      _notify();
      return false;
    }
    _comparisonIds.add(productId);
    _errorMessage = null;
    _notify();
    return true;
  }

  Future<void> loadMore() async {
    if (!_hasMore || _loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _paginationStatus = MarketplacePaginationStatus.loading;
    _notify();
    try {
      final MarketplacePageResult result = await _repository.getProducts(
        _query.copyWith(page: _query.page + 1),
      );
      _query = _query.copyWith(page: result.page);
      _products = List<InsuranceProduct>.unmodifiable(<InsuranceProduct>[
        ..._products,
        ...result.products,
      ]);
      _hasMore = result.hasMore;
      _paginationStatus = MarketplacePaginationStatus.idle;
    } catch (_) {
      _paginationStatus = MarketplacePaginationStatus.failure;
      _errorMessage = 'Unable to load more products.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  Future<void> _loadInitial() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = MarketplaceLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      await _replaceProducts(_query.copyWith(page: 1));
    } catch (_) {
      _loadStatus = MarketplaceLoadStatus.failure;
      _errorMessage = 'Unable to load insurance products. Please try again.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  Future<void> _loadForChangedQuery() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _refreshStatus = MarketplaceRefreshStatus.refreshing;
    _errorMessage = null;
    _notify();
    try {
      await _replaceProducts(_query.copyWith(page: 1));
      _refreshStatus = MarketplaceRefreshStatus.idle;
    } catch (_) {
      _refreshStatus = MarketplaceRefreshStatus.failure;
      _errorMessage = 'Unable to update marketplace results.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  Future<void> _replaceProducts(MarketplaceQuery query) async {
    final MarketplacePageResult result = await _repository.getProducts(query);
    _query = query.copyWith(page: result.page);
    _products = List<InsuranceProduct>.unmodifiable(result.products);
    _availableProviders.addAll(
      result.products.map((InsuranceProduct product) => product.providerName),
    );
    _hasMore = result.hasMore;
    _applyLoadedState();
  }

  void _applyLoadedState() {
    _loadStatus = products.isEmpty
        ? MarketplaceLoadStatus.empty
        : MarketplaceLoadStatus.success;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
