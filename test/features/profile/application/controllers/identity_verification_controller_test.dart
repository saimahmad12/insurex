import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';

void main() {
  group('IdentityVerificationController', () {
    test('loads verified identity state', () async {
      final IdentityVerificationController controller =
          IdentityVerificationController(
            repository: MockProfileRepository(delay: Duration.zero),
          );

      await controller.initialize();
      expect(controller.loadStatus, IdentityLoadStatus.success);
      expect(
        controller.verification?.status,
        IdentityVerificationStatus.verified,
      );
      expect(controller.verification?.maskedIdentityNumber, contains('*'));
    });

    test(
      'loads a not-started identity state without exposing the CNIC',
      () async {
        final UserProfile base = (await MockProfileRepository(
          delay: Duration.zero,
        ).getProfile())!;
        final MockProfileRepository repository = MockProfileRepository(
          delay: Duration.zero,
          initialProfile: base.copyWith(
            identityVerification: const IdentityVerification(
              status: IdentityVerificationStatus.notStarted,
              maskedIdentityNumber: '*****-*******-3',
            ),
          ),
        );
        final IdentityVerificationController controller =
            IdentityVerificationController(repository: repository);

        await controller.initialize();

        expect(
          controller.verification?.status,
          IdentityVerificationStatus.notStarted,
        );
        expect(controller.verification?.maskedIdentityNumber, contains('*'));
      },
    );

    for (final IdentityVerificationStatus status
        in <IdentityVerificationStatus>[
          IdentityVerificationStatus.pending,
          IdentityVerificationStatus.verified,
          IdentityVerificationStatus.rejected,
        ]) {
      test('maps mock start-verification outcome $status', () async {
        final IdentityVerificationController controller =
            IdentityVerificationController(
              repository: MockProfileRepository(
                delay: Duration.zero,
                verificationOutcome: status,
              ),
            );
        await controller.initialize();

        final IdentityVerification? result = await controller
            .startVerification();
        expect(result?.status, status);
        expect(controller.submissionStatus, IdentitySubmissionStatus.success);
        if (status == IdentityVerificationStatus.rejected) {
          expect(result?.rejectionReason, isNotNull);
        }
      });
    }

    test(
      'reports verification failure without changing loaded state',
      () async {
        final IdentityVerificationController controller =
            IdentityVerificationController(
              repository: MockProfileRepository(
                delay: Duration.zero,
                failVerification: true,
              ),
            );
        await controller.initialize();
        final IdentityVerification? original = controller.verification;

        expect(await controller.startVerification(), isNull);
        expect(controller.verification, same(original));
        expect(controller.submissionStatus, IdentitySubmissionStatus.failure);
      },
    );

    test('prevents duplicate verification submissions', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: const Duration(milliseconds: 10),
      );
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);
      await controller.initialize();

      final Future<IdentityVerification?> first = controller
          .startVerification();
      final Future<IdentityVerification?> duplicate = controller
          .startVerification();

      expect(await duplicate, isNull);
      expect(await first, isNotNull);
      expect(repository.verificationCallCount, 1);
    });
  });
}
