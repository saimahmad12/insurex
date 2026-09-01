import 'package:flutter/foundation.dart';

import '../../../profile/domain/entities/identity_verification.dart';
import '../../../profile/domain/repositories/identity_verification_repository.dart';
import '../../domain/entities/signup_request.dart';
import '../../domain/repositories/signup_repository.dart';

enum SignupStatus {
  idle,
  loading,
  awaitingIdentityVerification,
  completing,
  success,
  failure,
}

class SignupController extends ChangeNotifier {
  SignupController({
    required SignupRepository repository,
    required IdentityVerificationRepository identityRepository,
  }) : _repository = repository,
       _identityRepository = identityRepository;

  final SignupRepository _repository;
  final IdentityVerificationRepository _identityRepository;

  SignupStatus _status = SignupStatus.idle;
  String? _errorMessage;
  SignupRequest? _pendingRequest;
  bool _prepareInProgress = false;
  bool _completionInProgress = false;

  SignupStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get hasPendingSignup => _pendingRequest != null;

  String? get pendingFullName => _pendingRequest?.fullName;

  bool get isLoading =>
      _status == SignupStatus.loading || _status == SignupStatus.completing;

  Future<bool> prepareAccountDetails({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    final SignupRequest request = SignupRequest(
      fullName: fullName.trim(),
      email: email.trim(),
      mobileNumber: mobileNumber.trim(),
      password: password,
    );
    if (_prepareInProgress || _completionInProgress) {
      return false;
    }
    if (_status == SignupStatus.awaitingIdentityVerification &&
        _requestsMatch(_pendingRequest, request)) {
      return true;
    }

    _prepareInProgress = true;
    _status = SignupStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool prepared = await _repository.prepareSignup(request);

      if (prepared) {
        _pendingRequest = request;
        _status = SignupStatus.awaitingIdentityVerification;
        return true;
      }

      _status = SignupStatus.failure;
      _errorMessage =
          'Unable to prepare your account. Please check your information.';
      return false;
    } catch (_) {
      _status = SignupStatus.failure;
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _prepareInProgress = false;
      notifyListeners();
    }
  }

  static bool _requestsMatch(SignupRequest? current, SignupRequest proposed) {
    return current?.fullName == proposed.fullName &&
        current?.email == proposed.email &&
        current?.mobileNumber == proposed.mobileNumber &&
        current?.password == proposed.password;
  }

  Future<bool> completeVerifiedSignup() async {
    if (_status == SignupStatus.success) {
      return true;
    }
    if (_completionInProgress) {
      return false;
    }
    final SignupRequest? request = _pendingRequest;
    if (request == null) {
      _status = SignupStatus.failure;
      _errorMessage = 'Your signup details are unavailable. Please try again.';
      notifyListeners();
      return false;
    }

    _completionInProgress = true;
    _status = SignupStatus.completing;
    _errorMessage = null;
    notifyListeners();
    try {
      final IdentityVerification verification = await _identityRepository
          .getIdentityVerification();
      if (verification.status != IdentityVerificationStatus.verified) {
        _status = SignupStatus.awaitingIdentityVerification;
        return false;
      }
      final bool completed = await _repository.completeSignup(request);
      if (!completed) {
        _status = SignupStatus.failure;
        _errorMessage = 'Unable to complete your account. Please try again.';
        return false;
      }
      _status = SignupStatus.success;
      _pendingRequest = null;
      return true;
    } catch (_) {
      _status = SignupStatus.failure;
      _errorMessage = 'Unable to complete your account. Please try again.';
      return false;
    } finally {
      _completionInProgress = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _status = _pendingRequest == null
        ? SignupStatus.idle
        : SignupStatus.awaitingIdentityVerification;

    notifyListeners();
  }

  @override
  void dispose() {
    _pendingRequest = null;
    super.dispose();
  }
}
