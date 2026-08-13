import 'package:flutter/foundation.dart';

import '../../domain/entities/forgot_password_request.dart';
import '../../domain/repositories/password_recovery_repository.dart';

enum ForgotPasswordStatus {
  idle,
  loading,
  success,
  failure,
}

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({
    required PasswordRecoveryRepository repository,
  }) : _repository = repository;

  final PasswordRecoveryRepository _repository;

  ForgotPasswordStatus _status =
      ForgotPasswordStatus.idle;

  String? _errorMessage;

  ForgotPasswordStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == ForgotPasswordStatus.loading;

  bool get isSuccess =>
      _status == ForgotPasswordStatus.success;

  Future<bool> requestPasswordReset({
    required String identity,
  }) async {
    _status = ForgotPasswordStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final ForgotPasswordRequest request =
      ForgotPasswordRequest(
        identity: identity.trim(),
      );

      final bool sent =
      await _repository.requestPasswordReset(
        request,
      );

      if (sent) {
        _status = ForgotPasswordStatus.success;

        notifyListeners();

        return true;
      }

      _status = ForgotPasswordStatus.failure;

      _errorMessage =
      'Unable to send reset instructions. Please try again.';

      notifyListeners();

      return false;
    } catch (_) {
      _status = ForgotPasswordStatus.failure;

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
    _status = ForgotPasswordStatus.idle;

    notifyListeners();
  }

  void resetState() {
    _status = ForgotPasswordStatus.idle;
    _errorMessage = null;

    notifyListeners();
  }
}