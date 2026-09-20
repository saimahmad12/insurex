import 'package:flutter/foundation.dart';

import '../../domain/entities/forgot_password_request.dart';
import '../../domain/repositories/password_recovery_repository.dart';

enum ForgotPasswordStatus { idle, loading, success, failure }

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({required PasswordRecoveryRepository repository})
    : _repository = repository;

  final PasswordRecoveryRepository _repository;

  ForgotPasswordStatus _status = ForgotPasswordStatus.idle;

  String? _errorMessage;

  ForgotPasswordStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ForgotPasswordStatus.loading;

  bool get isSuccess => _status == ForgotPasswordStatus.success;

  Future<bool> requestPasswordReset({required String identity}) async {
    if (_disposed || isLoading) return false;
    _status = ForgotPasswordStatus.loading;
    _errorMessage = null;

    _notify();

    try {
      final ForgotPasswordRequest request = ForgotPasswordRequest(
        identity: identity.trim(),
      );

      final bool sent = await _repository.requestPasswordReset(request);

      if (sent) {
        _status = ForgotPasswordStatus.success;

        _notify();

        return true;
      }

      _status = ForgotPasswordStatus.failure;

      _errorMessage = 'Unable to send reset instructions. Please try again.';

      _notify();

      return false;
    } catch (_) {
      _status = ForgotPasswordStatus.failure;

      _errorMessage = 'Something went wrong. Please try again.';

      _notify();

      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _status = ForgotPasswordStatus.idle;

    _notify();
  }

  void resetState() {
    _status = ForgotPasswordStatus.idle;
    _errorMessage = null;

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
