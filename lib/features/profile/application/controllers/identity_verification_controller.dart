import 'package:flutter/foundation.dart';

import '../../domain/entities/identity_verification.dart';
import '../../domain/repositories/identity_verification_repository.dart';

enum IdentityLoadStatus { initial, loading, success, failure }

enum IdentitySubmissionStatus { idle, submitting, success, failure }

class IdentityVerificationController extends ChangeNotifier {
  IdentityVerificationController({
    required IdentityVerificationRepository repository,
  }) : _repository = repository;

  final IdentityVerificationRepository _repository;
  IdentityLoadStatus _loadStatus = IdentityLoadStatus.initial;
  IdentitySubmissionStatus _submissionStatus = IdentitySubmissionStatus.idle;
  IdentityVerification? _verification;
  String? _errorMessage;
  String? _submissionErrorMessage;
  bool _initialized = false;
  bool _loadInProgress = false;
  bool _submissionInProgress = false;
  bool _disposed = false;

  IdentityLoadStatus get loadStatus => _loadStatus;
  IdentitySubmissionStatus get submissionStatus => _submissionStatus;
  IdentityVerification? get verification => _verification;
  String? get errorMessage => _errorMessage;
  String? get submissionErrorMessage => _submissionErrorMessage;
  bool get isLoading =>
      _loadStatus == IdentityLoadStatus.loading && _verification == null;
  bool get isSubmitting =>
      _submissionStatus == IdentitySubmissionStatus.submitting;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
  }

  Future<void> retry() => _load();

  Future<IdentityVerification?> startVerification() async {
    if (_submissionInProgress) {
      return null;
    }
    _submissionInProgress = true;
    _submissionStatus = IdentitySubmissionStatus.submitting;
    _submissionErrorMessage = null;
    _notify();
    try {
      final IdentityVerification updated = await _repository
          .startIdentityVerification();
      _verification = updated;
      _submissionStatus = IdentitySubmissionStatus.success;
      return updated;
    } catch (_) {
      _submissionStatus = IdentitySubmissionStatus.failure;
      _submissionErrorMessage =
          'Unable to start verification. No identity documents were uploaded.';
      return null;
    } finally {
      _submissionInProgress = false;
      _notify();
    }
  }

  Future<void> _load() async {
    if (_loadInProgress) {
      return;
    }
    _loadInProgress = true;
    _loadStatus = IdentityLoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      _verification = await _repository.getIdentityVerification();
      _loadStatus = IdentityLoadStatus.success;
    } catch (_) {
      _loadStatus = IdentityLoadStatus.failure;
      _errorMessage = 'Unable to load identity verification.';
    } finally {
      _loadInProgress = false;
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
