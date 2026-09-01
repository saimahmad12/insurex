import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';

void main() {
  test('account details remain pending until identity is verified', () async {
    final MockProfileRepository profileRepository = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockSignupRepository repository = MockSignupRepository(
      initializeAccountName: profileRepository.initializeUnverifiedAccountName,
      delay: Duration.zero,
    );
    final SignupController controller = SignupController(
      repository: repository,
      identityRepository: profileRepository,
    );

    expect(await _prepare(controller), isTrue);
    expect(controller.status, SignupStatus.awaitingIdentityVerification);
    expect(controller.pendingFullName, 'Synthetic Policyholder');
    expect(repository.isCompleted, isFalse);
    expect(
      (await profileRepository.getProfile())?.identityVerification.status,
      IdentityVerificationStatus.notStarted,
    );

    expect(await controller.completeVerifiedSignup(), isFalse);
    expect(repository.isCompleted, isFalse);
    expect(controller.hasPendingSignup, isTrue);
  });

  for (final IdentityVerificationStatus status in <IdentityVerificationStatus>[
    IdentityVerificationStatus.submitted,
    IdentityVerificationStatus.pending,
    IdentityVerificationStatus.rejected,
    IdentityVerificationStatus.additionalCaptureRequired,
    IdentityVerificationStatus.technicalFailure,
  ]) {
    test('$status does not complete signup', () async {
      final MockProfileRepository profileRepository = MockProfileRepository(
        delay: Duration.zero,
        initialVerificationStatus: status,
      );
      final MockSignupRepository repository = MockSignupRepository(
        initializeAccountName: (_) async {},
        delay: Duration.zero,
      );
      final SignupController controller = SignupController(
        repository: repository,
        identityRepository: profileRepository,
      );

      await _prepare(controller);

      expect(await controller.completeVerifiedSignup(), isFalse);
      expect(repository.isCompleted, isFalse);
      expect(controller.hasPendingSignup, isTrue);
    });
  }

  test('verified identity completes signup exactly once', () async {
    final MockProfileRepository profileRepository = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockSignupRepository repository = MockSignupRepository(
      initializeAccountName: (_) async {},
      delay: Duration.zero,
    );
    final SignupController controller = SignupController(
      repository: repository,
      identityRepository: profileRepository,
    );
    await _prepare(controller);

    expect(await controller.completeVerifiedSignup(), isTrue);
    expect(await controller.completeVerifiedSignup(), isTrue);
    expect(controller.status, SignupStatus.success);
    expect(controller.hasPendingSignup, isFalse);
    expect(repository.completeCallCount, 1);
  });

  test(
    'duplicate account-detail submissions are ignored while loading',
    () async {
      final MockSignupRepository repository = MockSignupRepository(
        initializeAccountName: (_) async {},
        delay: const Duration(milliseconds: 15),
      );
      final SignupController controller = SignupController(
        repository: repository,
        identityRepository: MockProfileRepository(delay: Duration.zero),
      );

      final Future<bool> first = _prepare(controller);
      final Future<bool> duplicate = _prepare(controller);

      expect(await duplicate, isFalse);
      expect(await first, isTrue);
      expect(repository.prepareCallCount, 1);
    },
  );
}

Future<bool> _prepare(SignupController controller) {
  return controller.prepareAccountDetails(
    fullName: 'Synthetic Policyholder',
    email: 'policyholder@example.test',
    mobileNumber: '+923001234567',
    password: 'StrongPass1',
  );
}
