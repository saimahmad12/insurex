import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required AuthTokenStorage tokenStorage,
    http.Client? client,
  }) : _tokenStorage = tokenStorage,
        _client = client ?? http.Client();

  final AuthTokenStorage _tokenStorage;
  final http.Client _client;

  @override
  Future<bool> login(
      LoginCredentials credentials,
      ) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/auth/login',
    );

    final http.Response response =
    await _client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'identity':
          credentials.identity.trim(),
          'password':
          credentials.password,
        },
      ),
    );

    if (response.statusCode == 401) {
      return false;
    }

    if (response.statusCode != 200) {
      throw StateError(
        'Login failed with status ${response.statusCode}.',
      );
    }

    final Object? decoded =
    jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid login response.',
      );
    }

    final String? accessToken =
    decoded['accessToken'] as String?;

    final String? refreshToken =
    decoded['refreshToken'] as String?;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const FormatException(
        'Authentication tokens are missing.',
      );
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return true;
  }
}