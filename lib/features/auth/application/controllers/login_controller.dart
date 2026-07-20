import 'package:flutter/foundation.dart';

import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginStatus {
  idle,
  loading,
  success,
  failure,
}

class LoginController extends ChangeNotifier {
  LoginController({
    required AuthRepository repository,
  }) : _repository = repository;

  final AuthRepository _repository;

  LoginStatus _status = LoginStatus.idle;
  String? _errorMessage;

  LoginStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == LoginStatus.loading;

  Future<bool> login({
    required String identity,
    required String password,
  }) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final LoginCredentials credentials = LoginCredentials(
        identity: identity.trim(),
        password: password,
      );

      final bool authenticated =
      await _repository.login(credentials);

      if (authenticated) {
        _status = LoginStatus.success;
        notifyListeners();

        return true;
      }

      _status = LoginStatus.failure;
      _errorMessage =
      'Invalid mobile number, email, or password.';

      notifyListeners();

      return false;
    } catch (_) {
      _status = LoginStatus.failure;
      _errorMessage =
      'Unable to sign in. Please try again.';

      notifyListeners();

      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _status = LoginStatus.idle;

    notifyListeners();
  }
}