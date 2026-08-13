import 'package:flutter/foundation.dart';

import '../../domain/entities/signup_request.dart';
import '../../domain/repositories/signup_repository.dart';

enum SignupStatus {
  idle,
  loading,
  success,
  failure,
}

class SignupController extends ChangeNotifier {
  SignupController({
    required SignupRepository repository,
  }) : _repository = repository;

  final SignupRepository _repository;

  SignupStatus _status = SignupStatus.idle;
  String? _errorMessage;

  SignupStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == SignupStatus.loading;

  Future<bool> signup({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    _status = SignupStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final SignupRequest request = SignupRequest(
        fullName: fullName.trim(),
        email: email.trim(),
        mobileNumber: mobileNumber.trim(),
        password: password,
      );

      final bool registered =
      await _repository.signup(request);

      if (registered) {
        _status = SignupStatus.success;
        notifyListeners();

        return true;
      }

      _status = SignupStatus.failure;
      _errorMessage =
      'Unable to create your account. Please check your information.';

      notifyListeners();

      return false;
    } catch (_) {
      _status = SignupStatus.failure;
      _errorMessage =
      'Something went wrong. Please try again.';

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _status = SignupStatus.idle;

    notifyListeners();
  }
}