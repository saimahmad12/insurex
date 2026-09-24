import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../domain/entities/forgot_password_request.dart';
import '../../domain/entities/otp_verification_request.dart';
import '../../domain/entities/password_reset_session.dart';
import '../../domain/repositories/otp_verification_repository.dart';

class ApiOtpVerificationRepository implements OtpVerificationRepository {
  ApiOtpVerificationRepository({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<PasswordResetSession?> verifyOtp(
    OtpVerificationRequest request,
  ) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-reset-otp');

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{
            'identity': request.identity.trim(),
            'otp': request.code.trim(),
          }),
        )
        .timeout(requestTimeout);

    if (response.statusCode == 400) {
      return null;
    }

    if (response.statusCode != 200) {
      throw StateError(
        'OTP verification failed with status '
        '${response.statusCode}.',
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid OTP verification response.');
    }

    final Object? resetToken = decoded['resetToken'];

    if (resetToken is! String || resetToken.trim().isEmpty) {
      throw const FormatException('Password reset token is missing.');
    }

    return PasswordResetSession(
      identity: request.identity.trim(),
      resetToken: resetToken,
    );
  }

  @override
  Future<bool> resendOtp({required String identity}) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password');

    final ForgotPasswordRequest request = ForgotPasswordRequest(
      identity: identity.trim(),
    );

    final http.Response response = await _client
        .post(
          uri,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{'identity': request.identity}),
        )
        .timeout(requestTimeout);

    if (response.statusCode != 200) {
      throw StateError(
        'OTP resend failed with status '
        '${response.statusCode}.',
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid OTP resend response.');
    }

    return decoded['success'] == true;
  }
}
