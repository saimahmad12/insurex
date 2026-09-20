import 'package:flutter/foundation.dart';

import '../../domain/entities/account_role.dart';
import '../../domain/entities/seller_authentication.dart';
import '../../domain/entities/seller_registration.dart';
import '../../domain/repositories/seller_auth_repository.dart';
import '../validators/seller_auth_validator.dart';

enum SellerLoginStatus { idle, validating, authenticating, resolved, failure }

class SellerLoginController extends ChangeNotifier {
  SellerLoginController({
    required SellerAuthRepository repository,
    required SellerAuthValidator validator,
  }) : _repository = repository,
       _validator = validator;

  final SellerAuthRepository _repository;
  final SellerAuthValidator _validator;

  SellerLoginStatus _status = SellerLoginStatus.idle;
  Map<SellerLoginField, String> _fieldErrors = <SellerLoginField, String>{};
  String? _errorMessage;
  SellerAuthenticationResult? _result;

  SellerLoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  SellerAuthenticationResult? get result => _result;
  bool get isLoading => _status == SellerLoginStatus.authenticating;

  String? errorFor(SellerLoginField field) => _fieldErrors[field];

  Future<SellerAuthenticationResult?> login({
    required String businessEmail,
    required String password,
  }) async {
    if (isLoading) {
      return null;
    }

    _status = SellerLoginStatus.validating;
    _fieldErrors = _validator.validateLogin(
      businessEmail: businessEmail,
      password: password,
    );
    _errorMessage = null;
    _result = null;
    if (_fieldErrors.isNotEmpty) {
      _status = SellerLoginStatus.failure;
      _notify();
      return null;
    }

    _status = SellerLoginStatus.authenticating;
    _notify();
    try {
      final SellerAuthenticationResult result = await _repository.login(
        SellerLoginCredentials(
          businessEmail: businessEmail.trim().toLowerCase(),
          password: password,
        ),
      );
      if (!result.isAuthenticated) {
        _status = SellerLoginStatus.failure;
        _errorMessage = switch (result.failure) {
          SellerAuthenticationFailure.invalidCredentials =>
            'Invalid business email or password.',
          _ => 'Unable to sign in to the company portal. Please try again.',
        };
        return null;
      }

      final SellerAccount account = result.account!;
      if (account.authoritativeRole != AccountRole.seller) {
        _status = SellerLoginStatus.failure;
        _errorMessage =
            'This account is not authorized for the Insurance Company portal.';
        return null;
      }
      if (account.registrationStatus == SellerRegistrationStatus.draft ||
          account.registrationStatus == SellerRegistrationStatus.submitting ||
          account.registrationStatus ==
              SellerRegistrationStatus.technicalFailure) {
        _status = SellerLoginStatus.failure;
        _errorMessage =
            'This company account is not ready for login. Please try again later.';
        return null;
      }

      _result = result;
      _status = SellerLoginStatus.resolved;
      return result;
    } catch (_) {
      _status = SellerLoginStatus.failure;
      _errorMessage =
          'Unable to sign in to the company portal. Please try again.';
      return null;
    } finally {
      _notify();
    }
  }

  void clearFieldError(SellerLoginField field) {
    if (!_fieldErrors.containsKey(field) && _errorMessage == null) {
      return;
    }
    _fieldErrors = Map<SellerLoginField, String>.of(_fieldErrors)
      ..remove(field);
    _errorMessage = null;
    _status = SellerLoginStatus.idle;
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
