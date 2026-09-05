import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/application/controllers/login_controller.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/domain/entities/account_role.dart';
import 'package:insurancex/features/auth/domain/entities/login_credentials.dart';
import 'package:insurancex/features/auth/domain/entities/signup_request.dart';
import 'package:insurancex/features/auth/domain/repositories/auth_repository.dart';
import 'package:insurancex/features/auth/domain/repositories/signup_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';

void main() {
  group('LoginController account role', () {
    test('defaults to Customer and forwards it to the repository', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final LoginController controller = LoginController(
        repository: repository,
      );

      await controller.login(
        identity: ' customer@example.test ',
        password: 'password',
      );

      expect(repository.lastCredentials?.role, AccountRole.customer);
      expect(repository.lastCredentials?.identity, 'customer@example.test');
    });

    test('keeps customer authentication scoped to Customer', () async {
      final _RecordingAuthRepository repository = _RecordingAuthRepository();
      final LoginController controller = LoginController(
        repository: repository,
      );

      await controller.login(
        identity: 'customer@example.test',
        password: 'password',
      );

      expect(repository.lastCredentials?.role, AccountRole.customer);
    });
  });

  group('SignupController account role', () {
    test('defaults to the existing Customer signup journey', () async {
      final _RecordingSignupRepository repository =
          _RecordingSignupRepository();
      final SignupController controller = _signupController(repository);

      expect(await _prepare(controller), isTrue);

      expect(repository.lastPreparedRequest?.role, AccountRole.customer);
      expect(controller.status, SignupStatus.awaitingIdentityVerification);
    });
  });
}

SignupController _signupController(SignupRepository repository) {
  return SignupController(
    repository: repository,
    identityRepository: MockProfileRepository(delay: Duration.zero),
  );
}

Future<bool> _prepare(SignupController controller) {
  return controller.prepareAccountDetails(
    fullName: 'Synthetic Account Owner',
    email: 'owner@example.test',
    mobileNumber: '+923001234567',
    password: 'StrongPass1',
  );
}

class _RecordingAuthRepository implements AuthRepository {
  LoginCredentials? lastCredentials;

  @override
  Future<bool> login(LoginCredentials credentials) async {
    lastCredentials = credentials;
    return true;
  }
}

class _RecordingSignupRepository implements SignupRepository {
  SignupRequest? lastPreparedRequest;
  int completeCallCount = 0;

  @override
  Future<bool> prepareSignup(SignupRequest request) async {
    lastPreparedRequest = request;
    return true;
  }

  @override
  Future<bool> completeSignup(SignupRequest request) async {
    completeCallCount++;
    return true;
  }
}
