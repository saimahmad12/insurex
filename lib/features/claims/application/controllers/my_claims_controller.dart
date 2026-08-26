import 'package:flutter/foundation.dart';

import '../../domain/entities/claim_filter.dart';
import '../../domain/entities/insurance_claim.dart';
import '../../domain/repositories/claim_status_repository.dart';

enum MyClaimsLoadStatus { initial, loading, success, empty, failure }

enum ClaimsRefreshStatus { idle, refreshing, failure }

class MyClaimsController extends ChangeNotifier {
  MyClaimsController({required ClaimStatusRepository repository})
    : _repository = repository;

  final ClaimStatusRepository _repository;

  List<InsuranceClaim> _claims = const <InsuranceClaim>[];
  ClaimFilter _selectedFilter = ClaimFilter.all;
  String _searchQuery = '';
  MyClaimsLoadStatus _loadStatus = MyClaimsLoadStatus.initial;
  ClaimsRefreshStatus _refreshStatus = ClaimsRefreshStatus.idle;
  String? _errorMessage;
  String? _refreshErrorMessage;
  bool _initialized = false;
  bool _requestInProgress = false;
  bool _disposed = false;

  List<InsuranceClaim> get claims => _claims;
  ClaimFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  MyClaimsLoadStatus get loadStatus => _loadStatus;
  ClaimsRefreshStatus get refreshStatus => _refreshStatus;
  String? get errorMessage => _errorMessage;
  String? get refreshErrorMessage => _refreshErrorMessage;
  bool get isInitialLoading =>
      _loadStatus == MyClaimsLoadStatus.loading && _claims.isEmpty;
  bool get isRefreshing => _refreshStatus == ClaimsRefreshStatus.refreshing;

  int get totalClaimsCount => _claims.length;
  int get activeClaimsCount => _claims
      .where((InsuranceClaim claim) => claim.status.isActiveClaim)
      .length;
  int get approvedClaimsCount => _claims
      .where(
        (InsuranceClaim claim) =>
            claim.status.matchesFilter(ClaimFilter.approved),
      )
      .length;
  int get settledClaimsCount => _claims
      .where(
        (InsuranceClaim claim) =>
            claim.status.matchesFilter(ClaimFilter.settled),
      )
      .length;

  List<InsuranceClaim> get visibleClaims {
    final String normalizedQuery = _normalize(_searchQuery);
    return List<InsuranceClaim>.unmodifiable(
      _claims.where((InsuranceClaim claim) {
        if (!claim.status.matchesFilter(_selectedFilter)) {
          return false;
        }
        if (normalizedQuery.isEmpty) {
          return true;
        }

        return <String>[
          claim.id,
          claim.policyName,
          claim.policyNumber,
          claim.incidentType.name,
        ].any((String value) => _normalize(value).contains(normalizedQuery));
      }),
    );
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadInitial();
  }

  Future<void> refresh() async {
    if (_requestInProgress) {
      return;
    }

    _requestInProgress = true;
    _refreshStatus = ClaimsRefreshStatus.refreshing;
    _refreshErrorMessage = null;
    _notify();

    try {
      _claims = List<InsuranceClaim>.unmodifiable(
        await _repository.getClaims(),
      );
      _loadStatus = _claims.isEmpty
          ? MyClaimsLoadStatus.empty
          : MyClaimsLoadStatus.success;
      _refreshStatus = ClaimsRefreshStatus.idle;
    } catch (_) {
      _refreshStatus = ClaimsRefreshStatus.failure;
      _refreshErrorMessage =
          'Unable to refresh claims. Existing information is still shown.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
  }

  Future<void> retry() {
    if (_claims.isNotEmpty) {
      return refresh();
    }
    return _loadInitial();
  }

  void changeFilter(ClaimFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
    _notify();
  }

  void updateSearchQuery(String query) {
    if (_searchQuery == query) {
      return;
    }
    _searchQuery = query;
    _notify();
  }

  void clearSearch() {
    updateSearchQuery('');
  }

  Future<void> _loadInitial() async {
    if (_requestInProgress) {
      return;
    }

    _requestInProgress = true;
    _loadStatus = MyClaimsLoadStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      _claims = List<InsuranceClaim>.unmodifiable(
        await _repository.getClaims(),
      );
      _loadStatus = _claims.isEmpty
          ? MyClaimsLoadStatus.empty
          : MyClaimsLoadStatus.success;
    } catch (_) {
      _loadStatus = MyClaimsLoadStatus.failure;
      _errorMessage = 'Unable to load claims. Please try again.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
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
