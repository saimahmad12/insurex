import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification_draft.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';

void main() {
  group('IdentityVerificationController', () {
    test('initializes once and loads only masked identity data', () async {
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
      );
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);

      await Future.wait(<Future<void>>[
        controller.initialize(),
        controller.initialize(),
      ]);

      expect(repository.identityLoadCallCount, 1);
      expect(controller.loadStatus, IdentityLoadStatus.success);
      expect(
        controller.verification?.status,
        IdentityVerificationStatus.verified,
      );
      expect(controller.verification?.maskedIdentityNumber, startsWith('*'));
      expect(controller.accountName, 'Saim Ahmad');
    });

    test('requires unchecked consent before legal details', () async {
      final IdentityVerificationController controller =
          await _notStartedController();

      expect(await controller.startOrResumeVerification(), isTrue);
      expect(controller.flowStep, IdentityVerificationFlowStep.introduction);
      expect(controller.consentConfirmed, isFalse);
      expect(controller.continueFromIntroduction(), isFalse);

      controller.updateConsent(true);
      expect(controller.continueFromIntroduction(), isTrue);
      expect(controller.flowStep, IdentityVerificationFlowStep.legalDetails);
    });

    test('purchase launch initializes directly at the introduction', () async {
      final MockProfileRepository repository = await _notStartedRepository();
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);

      await controller.initialize(startImmediately: true);

      expect(repository.identityLoadCallCount, 1);
      expect(controller.flowStep, IdentityVerificationFlowStep.introduction);
      expect(controller.consentConfirmed, isFalse);
      expect(
        controller.verification?.status,
        IdentityVerificationStatus.capturing,
      );
    });

    test(
      'keeps front and back captures separate and rejects duplicates',
      () async {
        final IdentityVerificationController controller =
            await _notStartedController();
        await _reachCapture(controller);

        expect(
          await controller.registerCapture(
            _capture(IdentityCaptureSide.front, 'front-proof'),
          ),
          isTrue,
        );
        expect(
          controller.continueAfterCapture(IdentityCaptureSide.front),
          isTrue,
        );
        expect(
          await controller.registerCapture(
            _capture(IdentityCaptureSide.back, 'front-proof'),
          ),
          isFalse,
        );
        expect(controller.backCapture, isNull);

        expect(
          await controller.registerCapture(
            _capture(IdentityCaptureSide.back, 'back-proof'),
          ),
          isTrue,
        );
        await controller.retakeCapture(IdentityCaptureSide.back);
        expect(controller.frontCapture, isNotNull);
        expect(controller.backCapture, isNull);
      },
    );

    test(
      'resumes safe in-memory capture progress with a new controller',
      () async {
        final MockProfileRepository repository = await _notStartedRepository();
        final IdentityVerificationController first =
            IdentityVerificationController(repository: repository);
        await first.initialize();
        await _reachCapture(first);
        await first.registerCapture(
          _capture(IdentityCaptureSide.front, 'front-resume-proof'),
        );
        first.continueAfterCapture(IdentityCaptureSide.front);

        final IdentityVerificationController resumed =
            IdentityVerificationController(repository: repository);
        await resumed.initialize();
        await resumed.startOrResumeVerification();

        expect(resumed.frontCapture, isNotNull);
        expect(resumed.flowStep, IdentityVerificationFlowStep.backCapture);
      },
    );

    for (final IdentityVerificationStatus outcome
        in <IdentityVerificationStatus>[
          IdentityVerificationStatus.verified,
          IdentityVerificationStatus.pending,
          IdentityVerificationStatus.rejected,
          IdentityVerificationStatus.additionalCaptureRequired,
        ]) {
      test('maps secure mock verification outcome $outcome', () async {
        final IdentityVerificationController controller =
            await _notStartedController(outcome: outcome);
        await _completeEvidence(controller);

        final IdentityVerification? result = await controller
            .submitVerification();

        expect(result?.status, outcome);
        expect(controller.submissionStatus, IdentitySubmissionStatus.success);
        if (outcome == IdentityVerificationStatus.additionalCaptureRequired) {
          expect(
            controller.flowStep,
            IdentityVerificationFlowStep.frontCapture,
          );
        } else {
          expect(controller.flowStep, IdentityVerificationFlowStep.result);
        }
      });
    }

    test('prevents duplicate verification submission', () async {
      final MockProfileRepository repository = await _notStartedRepository(
        delay: const Duration(milliseconds: 10),
        outcome: IdentityVerificationStatus.pending,
      );
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);
      await controller.initialize();
      await _completeEvidence(controller);

      final Future<IdentityVerification?> first = controller
          .submitVerification();
      final Future<IdentityVerification?> duplicate = controller
          .submitVerification();

      expect(await duplicate, isNull);
      expect((await first)?.status, IdentityVerificationStatus.pending);
      expect(repository.verificationSubmissionCallCount, 1);
    });

    test(
      'normalizes name comparison without changing display casing',
      () async {
        final IdentityVerificationController controller =
            await _notStartedController();

        await _reachCapture(controller, fullName: '  SAIM   AHMAD  ');

        expect(controller.pendingVerificationName, 'SAIM AHMAD');
        expect(controller.hasMeaningfulNameChange, isFalse);
        expect(controller.isNameChangeConfirmed, isTrue);
      },
    );

    test(
      'requires confirmation and commits a changed name only after success',
      () async {
        final MockProfileRepository repository = await _notStartedRepository();
        final IdentityVerificationController controller =
            IdentityVerificationController(repository: repository);
        await controller.initialize();
        await _completeEvidence(controller, fullName: 'Muhammad Saim Ahmad');

        expect(controller.hasMeaningfulNameChange, isTrue);
        expect((await repository.getProfile())?.fullName, 'Saim Ahmad');
        expect(await controller.submitVerification(), isNull);
        expect(repository.verificationSubmissionCallCount, 0);
        expect((await repository.getProfile())?.fullName, 'Saim Ahmad');

        controller.confirmNameChange();
        expect(
          (await controller.submitVerification())?.status,
          IdentityVerificationStatus.verified,
        );
        expect(
          (await repository.refreshProfile())?.fullName,
          'Muhammad Saim Ahmad',
        );
        expect(controller.verifiedNameWasUpdated, isTrue);

        expect(
          (await controller.submitVerification())?.status,
          IdentityVerificationStatus.verified,
        );
        expect(repository.verificationSubmissionCallCount, 1);
      },
    );

    for (final IdentityVerificationStatus outcome
        in <IdentityVerificationStatus>[
          IdentityVerificationStatus.pending,
          IdentityVerificationStatus.rejected,
          IdentityVerificationStatus.technicalFailure,
          IdentityVerificationStatus.additionalCaptureRequired,
        ]) {
      test(
        '$outcome preserves the pending name without committing it',
        () async {
          final MockProfileRepository repository = await _notStartedRepository(
            outcome: outcome,
          );
          final IdentityVerificationController controller =
              IdentityVerificationController(repository: repository);
          await controller.initialize();
          await _completeEvidence(controller, fullName: 'Muhammad Saim Ahmad');
          controller.confirmNameChange();

          expect((await controller.submitVerification())?.status, outcome);
          expect((await repository.refreshProfile())?.fullName, 'Saim Ahmad');
          expect(controller.pendingVerificationName, 'Muhammad Saim Ahmad');
        },
      );
    }

    test('cancellation never partially updates the account name', () async {
      final MockProfileRepository repository = await _notStartedRepository();
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);
      await controller.initialize();
      await _reachCapture(controller, fullName: 'Muhammad Saim Ahmad');

      await controller.cancelVerification();

      expect((await repository.refreshProfile())?.fullName, 'Saim Ahmad');
      expect(controller.pendingVerificationName, isNull);
    });
  });
}

Future<IdentityVerificationController> _notStartedController({
  IdentityVerificationStatus outcome = IdentityVerificationStatus.verified,
}) async {
  final IdentityVerificationController controller =
      IdentityVerificationController(
        repository: await _notStartedRepository(outcome: outcome),
      );
  await controller.initialize();
  return controller;
}

Future<MockProfileRepository> _notStartedRepository({
  IdentityVerificationStatus outcome = IdentityVerificationStatus.verified,
  Duration delay = Duration.zero,
}) async {
  final UserProfile base = (await MockProfileRepository(
    delay: Duration.zero,
  ).getProfile())!;
  return MockProfileRepository(
    delay: delay,
    verificationOutcome: outcome,
    initialProfile: base.copyWith(
      identityVerification: const IdentityVerification(
        status: IdentityVerificationStatus.notStarted,
        maskedIdentityNumber: '*****-*******-3',
      ),
    ),
  );
}

Future<void> _reachCapture(
  IdentityVerificationController controller, {
  String? fullName,
}) async {
  await controller.startOrResumeVerification();
  controller.updateConsent(true);
  controller.continueFromIntroduction();
  controller.submitLegalDetails(
    IdentityLegalDetails(
      fullLegalName: fullName ?? controller.accountName,
      cnicNumber: _syntheticIdentityNumber(),
      dateOfBirth: DateTime(1990, 1, 1),
      gender: ProfileGender.preferNotToSay,
      cnicExpiryDate: DateTime.now().add(const Duration(days: 900)),
    ),
  );
}

Future<void> _completeEvidence(
  IdentityVerificationController controller, {
  String? fullName,
}) async {
  await _reachCapture(controller, fullName: fullName);
  await controller.registerCapture(
    _capture(IdentityCaptureSide.front, 'front-proof'),
  );
  controller.continueAfterCapture(IdentityCaptureSide.front);
  await controller.registerCapture(
    _capture(IdentityCaptureSide.back, 'back-proof'),
  );
  controller.continueAfterCapture(IdentityCaptureSide.back);
  await controller.registerCapture(
    _capture(IdentityCaptureSide.selfie, 'selfie-proof'),
  );
  controller.continueAfterCapture(IdentityCaptureSide.selfie);
}

IdentityCaptureInput _capture(IdentityCaptureSide side, String fingerprint) =>
    IdentityCaptureInput(
      side: side,
      temporaryPath: 'synthetic:${side.name}',
      fingerprint: fingerprint,
      quality: const IdentityCaptureQuality(
        width: 1600,
        height: 1000,
        fileSizeBytes: 120000,
        averageLuminance: 110,
        sharpnessScore: 12,
      ),
    );

String _syntheticIdentityNumber() => <String>[
  List<String>.filled(5, '1').join(),
  List<String>.filled(7, '2').join(),
  '3',
].join('-');
