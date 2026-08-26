import 'package:flutter/foundation.dart';

import '../../../payments/application/validators/payout_method_validator.dart';
import '../../../payments/domain/entities/payout_method.dart';
import '../../../payments/domain/repositories/claim_payout_repository.dart';

enum SavedPayoutMethodsLoadStatus { initial, loading, success, empty, failure }

enum SavedPayoutMethodOperationStatus {
  idle,
  adding,
  verifying,
  verificationPending,
  mutating,
  success,
  failure,
}

class SavedPayoutMethodsController extends ChangeNotifier {
  SavedPayoutMethodsController({required ClaimPayoutRepository repository})
    : _repository = repository;

  final ClaimPayoutRepository _repository;
  SavedPayoutMethodsLoadStatus _loadStatus =
      SavedPayoutMethodsLoadStatus.initial;
  SavedPayoutMethodOperationStatus _operationStatus =
      SavedPayoutMethodOperationStatus.idle;
  List<PayoutMethod> _methods = const <PayoutMethod>[];
  PayoutMethodType? _selectedType;
  String? _activeMethodId;
  String? _errorMessage;
  String? _operationErrorMessage;
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _operationInProgress = false;
  bool _disposed = false;

  SavedPayoutMethodsLoadStatus get loadStatus => _loadStatus;
  SavedPayoutMethodOperationStatus get operationStatus => _operationStatus;
  List<PayoutMethod> get methods => _methods;
  PayoutMethodType? get selectedType => _selectedType;
  String? get activeMethodId => _activeMethodId;
  String? get errorMessage => _errorMessage;
  String? get operationErrorMessage => _operationErrorMessage;
  bool get isLoading =>
      _loadStatus == SavedPayoutMethodsLoadStatus.loading && _methods.isEmpty;
  bool get isAddingOrVerifying =>
      _operationStatus == SavedPayoutMethodOperationStatus.adding ||
      _operationStatus == SavedPayoutMethodOperationStatus.verifying;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
  }

  Future<void> retry() => _load();

  void selectType(PayoutMethodType? type) {
    if (_selectedType == type) {
      return;
    }
    _selectedType = type;
    _operationErrorMessage = null;
    _operationStatus = SavedPayoutMethodOperationStatus.idle;
    _notify();
  }

  Future<bool> addAndVerifyMethod(PayoutMethodRequest request) async {
    if (_operationInProgress) {
      return false;
    }
    final Map<String, String> errors = PayoutMethodValidator.validate(request);
    if (errors.isNotEmpty) {
      _operationStatus = SavedPayoutMethodOperationStatus.failure;
      _operationErrorMessage = errors.values.first;
      _notify();
      return false;
    }
    _operationInProgress = true;
    _operationStatus = SavedPayoutMethodOperationStatus.adding;
    _operationErrorMessage = null;
    _notify();
    try {
      final PayoutMethod added = await _repository.addPayoutMethod(request);
      _activeMethodId = added.id;
      _operationStatus = SavedPayoutMethodOperationStatus.verifying;
      _notify();
      final PayoutMethod verified = await _repository.verifyPayoutMethod(
        added.id,
      );
      _upsert(verified);
      if (verified.verificationStatus ==
          PayoutMethodVerificationStatus.verificationPending) {
        _operationStatus = SavedPayoutMethodOperationStatus.verificationPending;
        _operationErrorMessage = 'Payout method verification is pending.';
        return false;
      }
      if (!verified.isVerified) {
        _operationStatus = SavedPayoutMethodOperationStatus.failure;
        _operationErrorMessage = 'The payout method could not be verified.';
        return false;
      }
      _operationStatus = SavedPayoutMethodOperationStatus.success;
      _selectedType = null;
      _syncLoadStatus();
      return true;
    } catch (_) {
      _operationStatus = SavedPayoutMethodOperationStatus.failure;
      _operationErrorMessage = 'Unable to add this payout method.';
      return false;
    } finally {
      _activeMethodId = null;
      _operationInProgress = false;
      _notify();
    }
  }

  Future<bool> verifyMethod(PayoutMethod method) async {
    if (_operationInProgress) {
      return false;
    }
    _operationInProgress = true;
    _activeMethodId = method.id;
    _operationStatus = SavedPayoutMethodOperationStatus.verifying;
    _operationErrorMessage = null;
    _notify();
    try {
      final PayoutMethod verified = await _repository.verifyPayoutMethod(
        method.id,
      );
      _upsert(verified);
      _operationStatus = verified.isVerified
          ? SavedPayoutMethodOperationStatus.success
          : verified.verificationStatus ==
                PayoutMethodVerificationStatus.verificationPending
          ? SavedPayoutMethodOperationStatus.verificationPending
          : SavedPayoutMethodOperationStatus.failure;
      if (!verified.isVerified) {
        _operationErrorMessage = 'Payout method verification is not complete.';
      }
      return verified.isVerified;
    } catch (_) {
      _operationStatus = SavedPayoutMethodOperationStatus.failure;
      _operationErrorMessage = 'Unable to verify this payout method.';
      return false;
    } finally {
      _activeMethodId = null;
      _operationInProgress = false;
      _notify();
    }
  }

  Future<bool> setDefault(PayoutMethod method) async {
    if (method.isDefault || _operationInProgress) {
      return false;
    }
    return _mutate(
      method.id,
      () => _repository.setDefaultPayoutMethod(method.id),
      'Unable to set this payout method as default.',
    );
  }

  Future<bool> remove(PayoutMethod method) {
    if (_operationInProgress) {
      return Future<bool>.value(false);
    }
    return _mutate(
      method.id,
      () => _repository.removePayoutMethod(method.id),
      'Unable to remove this payout method.',
    );
  }

  Future<bool> _mutate(
    String methodId,
    Future<List<PayoutMethod>> Function() operation,
    String failureMessage,
  ) async {
    _operationInProgress = true;
    _activeMethodId = methodId;
    _operationStatus = SavedPayoutMethodOperationStatus.mutating;
    _operationErrorMessage = null;
    _notify();
    try {
      _methods = List<PayoutMethod>.unmodifiable(await operation());
      _operationStatus = SavedPayoutMethodOperationStatus.success;
      _syncLoadStatus();
      return true;
    } catch (_) {
      _operationStatus = SavedPayoutMethodOperationStatus.failure;
      _operationErrorMessage = failureMessage;
      return false;
    } finally {
      _activeMethodId = null;
      _operationInProgress = false;
      _notify();
    }
  }

  Future<void> _load() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = SavedPayoutMethodsLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _methods = List<PayoutMethod>.unmodifiable(
        await _repository.getPayoutMethods(),
      );
      _syncLoadStatus();
    } catch (_) {
      _loadStatus = SavedPayoutMethodsLoadStatus.failure;
      _errorMessage = 'Unable to load saved payout methods.';
    } finally {
      _loadInProgress = false;
      _notify();
    }
  }

  void _upsert(PayoutMethod method) {
    _methods = List<PayoutMethod>.unmodifiable(<PayoutMethod>[
      ..._methods.where((PayoutMethod item) => item.id != method.id),
      method,
    ]);
    _syncLoadStatus();
  }

  void _syncLoadStatus() {
    _loadStatus = _methods.isEmpty
        ? SavedPayoutMethodsLoadStatus.empty
        : SavedPayoutMethodsLoadStatus.success;
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
