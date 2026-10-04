import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/security_settings.dart';
import '../../domain/repositories/security_repository.dart';

class ApiSecurityRepository implements SecurityRepository {
  ApiSecurityRepository({
    required AuthTokenStorage tokenStorage,
    required SecurityRepository settingsRepository,
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _tokenStorage = tokenStorage,
       _settingsRepository = settingsRepository,
       _client = client ?? http.Client();

  final AuthTokenStorage _tokenStorage;
  final SecurityRepository _settingsRepository;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final String? accessToken = await _tokenStorage.readAccessToken();

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw StateError('Authentication is required.');
    }

    final http.Response response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/change-password'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(<String, dynamic>{
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'confirmPassword': newPassword,
          }),
        )
        .timeout(requestTimeout);

    if (response.statusCode == 401) {
      await _tokenStorage.clearTokens();

      throw StateError('Your session has expired. Please sign in again.');
    }

    if (response.statusCode != 200) {
      throw StateError(
        _readMessage(response, fallback: 'Unable to change password.'),
      );
    }

    // The backend revokes all refresh sessions
    // after a successful password change.
    // Remove the local tokens as well so the
    // user must authenticate again.
    await _tokenStorage.clearTokens();
  }

  @override
  Future<SecuritySettings> getSecuritySettings() {
    return _settingsRepository.getSecuritySettings();
  }

  @override
  Future<SecuritySettings> updateSecuritySettings(SecuritySettings settings) {
    return _settingsRepository.updateSecuritySettings(settings);
  }

  String _readMessage(http.Response response, {required String fallback}) {
    try {
      final Object? decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final Object? message = decoded['message'];

        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Use the safe fallback below.
    }

    return fallback;
  }
}
