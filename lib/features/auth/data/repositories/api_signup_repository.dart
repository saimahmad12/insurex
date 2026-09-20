import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/signup_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/signup_repository.dart';

class ApiSignupRepository implements SignupRepository {
  ApiSignupRepository({
    required AuthRepository authRepository,
    required Future<void> Function(String fullName)
    initializeAccountName,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _authRepository = authRepository,
        _initializeAccountName = initializeAccountName,
        _client = client ?? http.Client();

  final AuthRepository _authRepository;

  final Future<void> Function(String fullName)
  _initializeAccountName;

  final http.Client _client;

  final Duration requestTimeout;

  @override
  Future<bool> prepareSignup(
      SignupRequest request,
      ) async {
    if (!_isValid(request)) {
      return false;
    }

    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/auth/register',
    );

    final http.Response response = await _client
        .post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'name': request.fullName.trim(),
          'email': request.email.trim(),
          'mobile': request.mobileNumber.trim(),
          'password': request.password,
          'confirmPassword': request.password,
        },
      ),
    )
        .timeout(requestTimeout);

    if (response.statusCode != 201 &&
        response.statusCode != 409) {
      throw StateError(
        'Signup failed with status ${response.statusCode}.',
      );
    }

    final bool authenticated =
    await _authRepository.login(
      LoginCredentials(
        identity: request.email.trim(),
        password: request.password,
        role: request.role,
      ),
    );

    if (!authenticated) {
      return false;
    }

    await _initializeAccountName(
      request.fullName,
    );

    return true;
  }

  @override
  Future<bool> completeSignup(
      SignupRequest request,
      ) async {
    if (!_isValid(request)) {
      return false;
    }

    // SignupController already checks that identity
    // verification is verified before calling this.
    return true;
  }

  bool _isValid(
      SignupRequest request,
      ) {
    return request.fullName.trim().isNotEmpty &&
        request.email.trim().isNotEmpty &&
        request.mobileNumber.trim().isNotEmpty &&
        request.password.length >= 8;
  }
}