import 'package:flutter/foundation.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginController extends ChangeNotifier {
  LoginController({required AuthRepository repository})
    : _repository = repository;

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
    if (_disposed || isLoading) return false;
    _status = LoginStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      final LoginCredentials credentials = LoginCredentials(
        identity: identity.trim(),
        password: password,
        role: AccountRole.customer,
      );

      final bool authenticated = await _repository.login(credentials);

      if (authenticated) {
        _status = LoginStatus.success;
        _notify();

        return true;
      }

      _status = LoginStatus.failure;
      _errorMessage = 'Invalid mobile number, email, or password.';

      _notify();

      return false;
    } catch (_) {
      _status = LoginStatus.failure;
      _errorMessage = 'Unable to sign in. Please try again.';

      _notify();

      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _status = LoginStatus.idle;

    _notify();
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
