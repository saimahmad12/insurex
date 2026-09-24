import 'package:flutter/foundation.dart';

import '../../domain/entities/otp_verification_request.dart';
import '../../domain/repositories/otp_verification_repository.dart';
import '../../domain/entities/password_reset_session.dart';

enum OtpVerificationStatus {
  idle,
  verifying,
  verified,
  failure,
  resending,
  resent,
}

class OtpVerificationController extends ChangeNotifier {
  OtpVerificationController({required OtpVerificationRepository repository})
    : _repository = repository;

  final OtpVerificationRepository _repository;

  OtpVerificationStatus _status = OtpVerificationStatus.idle;

  String? _errorMessage;
  String? _successMessage;

  OtpVerificationStatus get status => _status;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  bool get isVerifying => _status == OtpVerificationStatus.verifying;

  bool get isResending => _status == OtpVerificationStatus.resending;

  Future<PasswordResetSession?> verifyOtp({
    required String identity,
    required String code,
  }) async {
    if (_disposed || isVerifying || isResending) {
      return null;
    }

    _status = OtpVerificationStatus.verifying;
    _errorMessage = null;
    _successMessage = null;

    _notify();

    try {
      final OtpVerificationRequest request = OtpVerificationRequest(
        identity: identity.trim(),
        code: code.trim(),
      );

      final PasswordResetSession? session = await _repository.verifyOtp(
        request,
      );

      if (session != null) {
        _status = OtpVerificationStatus.verified;

        _notify();

        return session;
      }

      _status = OtpVerificationStatus.failure;
      _errorMessage = 'Invalid verification code. Please try again.';

      _notify();

      return null;
    } catch (_) {
      _status = OtpVerificationStatus.failure;
      _errorMessage = 'Unable to verify the code. Please try again.';

      _notify();

      return null;
    }
  }

  Future<void> resendOtp({required String identity}) async {
    if (_disposed || isVerifying || isResending) {
      return;
    }

    _status = OtpVerificationStatus.resending;
    _errorMessage = null;
    _successMessage = null;

    _notify();

    try {
      final bool sent = await _repository.resendOtp(identity: identity);

      if (sent) {
        _status = OtpVerificationStatus.resent;

        _successMessage = 'A new verification code has been sent.';
      } else {
        _status = OtpVerificationStatus.failure;

        _errorMessage = 'Unable to resend the code.';
      }
    } catch (_) {
      _status = OtpVerificationStatus.failure;

      _errorMessage = 'Unable to resend the code. Please try again.';
    }

    _notify();
  }

  void clearMessage() {
    _errorMessage = null;
    _successMessage = null;

    if (_status != OtpVerificationStatus.verifying &&
        _status != OtpVerificationStatus.resending) {
      _status = OtpVerificationStatus.idle;
    }

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
