import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../domain/entities/reset_password_request.dart';
import '../../domain/repositories/reset_password_repository.dart';

class ApiResetPasswordRepository implements ResetPasswordRepository {
  ApiResetPasswordRepository({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password');

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{
            'resetToken': request.resetToken.trim(),
            'newPassword': request.newPassword,
            'confirmPassword': request.confirmPassword,
          }),
        )
        .timeout(requestTimeout);

    if (response.statusCode == 400) {
      return false;
    }

    if (response.statusCode != 200) {
      throw StateError(
        'Password reset failed with status '
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
