import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthTokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> clearTokens();
}

class SecureAuthTokenStorage implements AuthTokenStorage {
  SecureAuthTokenStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(
      key: _accessTokenKey,
    );
  }

  @override
  Future<String?> readRefreshToken() {
    return _storage.read(
      key: _refreshTokenKey,
    );
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(
      key: _accessTokenKey,
    );

    await _storage.delete(
      key: _refreshTokenKey,
    );
  }
}