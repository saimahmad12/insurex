import 'package:flutter/foundation.dart';

import '../../domain/entities/insurance_product.dart';
import '../../domain/repositories/insurance_marketplace_repository.dart';

enum InsuranceProductLoadStatus { initial, loading, success, notFound, failure }

class InsuranceProductController extends ChangeNotifier {
  InsuranceProductController({
    required String productId,
    required InsuranceMarketplaceRepository repository,
  }) : _productId = productId,
       _repository = repository;

  final String _productId;
  final InsuranceMarketplaceRepository _repository;
  InsuranceProductLoadStatus _status = InsuranceProductLoadStatus.initial;
  InsuranceProduct? _product;
  String? _errorMessage;
  bool _initialized = false;
  bool _requestInProgress = false;
  bool _isFavourite = false;
  bool _disposed = false;

  InsuranceProductLoadStatus get status => _status;
  InsuranceProduct? get product => _product;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _status == InsuranceProductLoadStatus.loading && _product == null;
  bool get isFavourite => _isFavourite;

  void toggleFavourite() {
    _isFavourite = !_isFavourite;
    _notify();
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    if (_requestInProgress) {
      return;
    }
    _requestInProgress = true;
    _status = InsuranceProductLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _product = await _repository.getProductById(_productId);
      _status = _product == null
          ? InsuranceProductLoadStatus.notFound
          : InsuranceProductLoadStatus.success;
    } catch (_) {
      _status = InsuranceProductLoadStatus.failure;
      _errorMessage = 'Unable to load this insurance product.';
    } finally {
      _requestInProgress = false;
      _notify();
    }
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
