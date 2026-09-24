import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../domain/entities/forgot_password_request.dart';
import '../../domain/repositories/password_recovery_repository.dart';

class ApiPasswordRecoveryRepository implements PasswordRecoveryRepository {
  ApiPasswordRecoveryRepository({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<bool> requestPasswordReset(ForgotPasswordRequest request) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password');

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{
            'identity': request.identity.trim(),
          }),
        )
        .timeout(requestTimeout);

    if (response.statusCode != 200) {
      throw StateError(
        'Password reset request failed with status '
        '${response.statusCode}.',
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid password reset response.');
    }

    return decoded['success'] == true;
  }
}
