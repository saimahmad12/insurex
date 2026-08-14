import 'package:flutter/foundation.dart';

import '../../domain/entities/reset_password_request.dart';
import '../../domain/repositories/reset_password_repository.dart';

enum ResetPasswordStatus {
  idle,
  loading,
  success,
  failure,
}

class ResetPasswordController extends ChangeNotifier {
  ResetPasswordController({
    required ResetPasswordRepository repository,
  }) : _repository = repository;

  final ResetPasswordRepository _repository;

  ResetPasswordStatus _status =
      ResetPasswordStatus.idle;

  String? _errorMessage;

  ResetPasswordStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == ResetPasswordStatus.loading;

  bool get isSuccess =>
      _status == ResetPasswordStatus.success;

  Future<bool> resetPassword({
    required String identity,
    required String newPassword,
  }) async {
    if (isLoading) {
      return false;
    }

    _status = ResetPasswordStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final ResetPasswordRequest request =
      ResetPasswordRequest(
        identity: identity.trim(),
        newPassword: newPassword,
      );

      final bool success =
      await _repository.resetPassword(
        request,
      );

      if (success) {
        _status = ResetPasswordStatus.success;

        notifyListeners();

        return true;
      }

      _status = ResetPasswordStatus.failure;

      _errorMessage =
      'Unable to reset your password. Please try again.';

      notifyListeners();

      return false;
    } catch (_) {
      _status = ResetPasswordStatus.failure;

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
    _status = ResetPasswordStatus.idle;

    notifyListeners();
  }
}