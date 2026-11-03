import 'package:insurancex/features/auth/domain/entities/account_role.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:insurancex/core/storage/auth_token_storage.dart';
import 'package:insurancex/features/auth/application/controllers/login_controller.dart';
import 'package:insurancex/features/auth/application/controllers/otp_verification_controller.dart';
import 'package:insurancex/features/auth/data/repositories/api_auth_repository.dart';
import 'package:insurancex/features/auth/domain/entities/login_credentials.dart';
import 'package:insurancex/features/auth/domain/entities/otp_verification_request.dart';
import 'package:insurancex/features/auth/domain/repositories/auth_repository.dart';
import 'package:insurancex/features/auth/domain/repositories/otp_verification_repository.dart';
import 'package:insurancex/features/claims/application/validators/claim_form_validator.dart';
import 'package:insurancex/features/profile/data/repositories/token_auth_session_repository.dart';
import 'package:insurancex/features/policy_purchase/application/validators/beneficiary_validator.dart';
import 'package:insurancex/features/policy_purchase/domain/entities/beneficiary.dart';
import 'package:insurancex/features/auth/domain/entities/password_reset_session.dart';

void main() {
  test(
    'login ignores duplicate submissions and completes safely after disposal',
    () async {
      final repository = _AuthRepository();
      final controller = LoginController(repository: repository);
      final pending = controller.login(
        identity: 'test@example.com',
        password: 'password',
      );
      expect(
        await controller.login(
          identity: 'other@example.com',
          password: 'password',
        ),
        isFalse,
      );
      expect(repository.calls, 1);
      controller.dispose();
      repository.result.complete(true);
      await expectLater(pending, completes);
    },
  );

  test(
    'login failure after disposal does not notify a disposed controller',
    () async {
      final repository = _AuthRepository();
      final controller = LoginController(repository: repository);
      final pending = controller.login(
        identity: 'test@example.com',
        password: 'password',
      );
      controller.dispose();
      repository.result.completeError(StateError('offline'));
      expect(await pending, isFalse);
    },
  );

  test('OTP verification excludes resend and duplicate verification', () async {
    final repository = _OtpRepository();

    final controller = OtpVerificationController(repository: repository);

    final Future<PasswordResetSession?> pending = controller.verifyOtp(
      identity: 'test@example.com',
      code: '123456',
    );

    // A second verification request must be ignored
    // while the first one is still running.
    expect(
      await controller.verifyOtp(identity: 'test@example.com', code: '123456'),
      isNull,
    );

    // Resend must also be ignored while verification
    // is already in progress.
    await controller.resendOtp(identity: 'test@example.com');

    expect(repository.verifyCalls, 1);
    expect(repository.resendCalls, 0);

    controller.dispose();

    repository.result.complete(
      const PasswordResetSession(
        identity: 'test@example.com',
        resetToken: 'test-reset-token',
      ),
    );

    await expectLater(pending, completes);
  });

  test('logout deletes both authentication tokens', () async {
    final storage = _TokenStorage();

    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');

    final client = MockClient((request) async {
      expect(request.method, 'POST');

      expect(request.url.path, '/api/auth/logout');

      expect(request.body, contains('"refreshToken":"refresh"'));

      return http.Response('{"success":true}', 200);
    });

    addTearDown(client.close);

    final repository = TokenAuthSessionRepository(
      tokenStorage: storage,
      client: client,
    );

    await repository.logout();

    expect(await storage.readAccessToken(), isNull);

    expect(await storage.readRefreshToken(), isNull);
  });

  test('API validates token types before storing credentials', () async {
    final storage = _TokenStorage();
    final client = MockClient(
      (_) async =>
          http.Response('{"accessToken":123,"refreshToken":"refresh"}', 200),
    );
    addTearDown(client.close);
    final repository = ApiAuthRepository(tokenStorage: storage, client: client);
    await expectLater(
      repository.login(
        const LoginCredentials(
          role: AccountRole.customer,
          identity: 'test@example.com',
          password: 'password',
        ),
      ),
      throwsFormatException,
    );
    expect(storage.access, isNull);
  });

  test(
    'API login times out instead of leaving login loading forever',
    () async {
      final response = Completer<http.Response>();
      final client = MockClient((_) => response.future);
      addTearDown(client.close);
      final repository = ApiAuthRepository(
        tokenStorage: _TokenStorage(),
        client: client,
        requestTimeout: const Duration(milliseconds: 1),
      );
      await expectLater(
        repository.login(
          const LoginCredentials(
            role: AccountRole.customer,
            identity: 'test@example.com',
            password: 'password',
          ),
        ),
        throwsA(isA<TimeoutException>()),
      );
      response.complete(http.Response('', 401));
    },
  );

  test('claim amounts reject non-finite input', () {
    for (final value in ['NaN', 'Infinity', '-Infinity', '1e999']) {
      expect(
        ClaimFormValidator.validateEstimatedLoss(value),
        isNotNull,
        reason: value,
      );
    }
    expect(ClaimFormValidator.validateEstimatedLoss('25,000.50'), isNull);
  });

  test('beneficiary allocation cannot bypass total using NaN', () {
    final errors = BeneficiaryValidator.validate([
      PolicyBeneficiary(
        legalName: 'Test Person',
        relationship: 'Sibling',
        dateOfBirth: DateTime(1990),
        contactDetails: '03001234567',
        allocationPercentage: double.nan,
      ),
    ]);
    expect(errors, contains('beneficiaries'));
    expect(errors, contains('allocation'));
  });
}

class _AuthRepository implements AuthRepository {
  final result = Completer<bool>();
  int calls = 0;
  @override
  Future<bool> login(LoginCredentials credentials) {
    calls++;
    return result.future;
  }
}

class _OtpRepository implements OtpVerificationRepository {
  final Completer<PasswordResetSession?> result =
      Completer<PasswordResetSession?>();

  int verifyCalls = 0;
  int resendCalls = 0;

  @override
  Future<PasswordResetSession?> verifyOtp(OtpVerificationRequest request) {
    verifyCalls++;

    return result.future;
  }

  @override
  Future<bool> resendOtp({required String identity}) async {
    resendCalls++;

    return true;
  }
}

class _TokenStorage implements AuthTokenStorage {
  String? access;
  String? refresh;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<String?> readAccessToken() async => access;
  @override
  Future<String?> readRefreshToken() async => refresh;
  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }
}
