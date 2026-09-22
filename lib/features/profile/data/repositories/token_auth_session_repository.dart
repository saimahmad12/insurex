import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/repositories/auth_session_repository.dart';

class TokenAuthSessionRepository implements AuthSessionRepository {
  TokenAuthSessionRepository({
    required AuthTokenStorage tokenStorage,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _tokenStorage = tokenStorage,
       _client = client ?? http.Client();

  final AuthTokenStorage _tokenStorage;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<bool> restoreSession() async {
    final String? accessToken = await _tokenStorage.readAccessToken();

    final String? refreshToken = await _tokenStorage.readRefreshToken();

    // No saved session at all.
    if ((accessToken == null || accessToken.trim().isEmpty) &&
        (refreshToken == null || refreshToken.trim().isEmpty)) {
      return false;
    }

    // ----------------------------------------------------------
    // 1. Try the current access token first.
    // ----------------------------------------------------------
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      final bool? accessTokenValid = await _validateAccessToken(accessToken);

      if (accessTokenValid == true) {
        return true;
      }

      // null means an unexpected server/network problem.
      if (accessTokenValid == null) {
        throw StateError('Unable to validate the current session.');
      }
    }

    // ----------------------------------------------------------
    // 2. Access token expired/invalid.
    //    Try the refresh token.
    // ----------------------------------------------------------
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      await _tokenStorage.clearTokens();
      return false;
    }

    final String? newAccessToken = await _refreshSession(refreshToken);

    if (newAccessToken == null) {
      await _tokenStorage.clearTokens();
      return false;
    }

    // ----------------------------------------------------------
    // 3. Confirm the newly issued access token works.
    // ----------------------------------------------------------
    final bool? refreshedTokenValid = await _validateAccessToken(
      newAccessToken,
    );

    if (refreshedTokenValid == true) {
      return true;
    }

    if (refreshedTokenValid == false) {
      await _tokenStorage.clearTokens();
      return false;
    }

    throw StateError('Unable to validate the refreshed session.');
  }

  @override
  Future<void> logout() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();

    try {
      if (refreshToken != null && refreshToken.trim().isNotEmpty) {
        await _client
            .post(
              Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(<String, dynamic>{'refreshToken': refreshToken}),
            )
            .timeout(requestTimeout);
      }
    } finally {
      // Always log out locally even if the backend
      // is temporarily unavailable.
      await _tokenStorage.clearTokens();
    }
  }

  Future<bool?> _validateAccessToken(String accessToken) async {
    final http.Response response = await _client
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
          headers: <String, String>{
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        )
        .timeout(requestTimeout);

    if (response.statusCode == 200) {
      return true;
    }

    if (response.statusCode == 401) {
      return false;
    }

    return null;
  }

  Future<String?> _refreshSession(String refreshToken) async {
    final http.Response response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{'refreshToken': refreshToken}),
        )
        .timeout(requestTimeout);

    // Invalid or expired refresh token.
    if (response.statusCode == 400 || response.statusCode == 401) {
      return null;
    }

    if (response.statusCode != 200) {
      throw StateError(
        'Session refresh failed with status '
        '${response.statusCode}.',
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid refresh response.');
    }

    final Object? newAccessToken = decoded['accessToken'];

    final Object? newRefreshToken = decoded['refreshToken'];

    if (newAccessToken is! String ||
        newAccessToken.trim().isEmpty ||
        newRefreshToken is! String ||
        newRefreshToken.trim().isEmpty) {
      throw const FormatException('Authentication tokens are missing.');
    }

    await _tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    return newAccessToken;
  }
}
