import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/dashboard/application/controllers/dashboard_controller.dart';
import 'package:insurancex/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:insurancex/features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'package:insurancex/features/policies/data/repositories/mock_policies_repository.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/application/controllers/profile_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification_draft.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/policy_purchase/application/controllers/policy_purchase_controller.dart';
import 'package:insurancex/features/policy_purchase/data/repositories/mock_policy_purchase_repository.dart';

void main() {
  test(
    'verified name refreshes Profile and Dashboard from one source',
    () async {
      final UserProfile base = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
        verificationOutcome: IdentityVerificationStatus.verified,
        initialProfile: base.copyWith(
          identityVerification: const IdentityVerification(
            status: IdentityVerificationStatus.notStarted,
            maskedIdentityNumber: '*****-*******-*',
          ),
        ),
      );
      final ProfileController profileController = ProfileController(
        profileRepository: repository,
        authSessionRepository: MockAuthSessionRepository(delay: Duration.zero),
      );
      final DashboardController dashboardController = DashboardController(
        repository: MockDashboardRepository(profileRepository: repository),
      );
      final IdentityVerificationController identityController =
          IdentityVerificationController(repository: repository);
      final MockSignupRepository signupRepository = MockSignupRepository(
        initializeAccountName: repository.initializeUnverifiedAccountName,
        delay: Duration.zero,
      );
      final SignupController signupController = SignupController(
        repository: signupRepository,
        identityRepository: repository,
      );

      expect(
        await signupController.prepareAccountDetails(
          fullName: 'Saim Ahmad',
          email: 'policyholder@example.test',
          mobileNumber: '+923001234567',
          password: 'StrongPass1',
        ),
        isTrue,
      );

      await Future.wait(<Future<void>>[
        profileController.initialize(),
        dashboardController.loadDashboard(),
        identityController.initialize(),
      ]);
      await _completeVerifiedNameChange(identityController);
      expect(await signupController.completeVerifiedSignup(), isTrue);
      expect(signupRepository.completeCallCount, 1);

      expect(profileController.profile?.fullName, 'Saim Ahmad');
      expect(dashboardController.summary?.userName, 'Saim Ahmad');

      await Future.wait(<Future<void>>[
        profileController.refresh(),
        dashboardController.refreshDashboard(),
      ]);

      expect(profileController.profile?.fullName, 'Muhammad Saim Ahmad');
      expect(dashboardController.summary?.userName, 'Muhammad Saim Ahmad');

      final MockPolicyPurchaseRepository purchaseRepository =
          MockPolicyPurchaseRepository(
            identityRepository: repository,
            policiesRepository: MockPoliciesRepository(delay: Duration.zero),
            delay: Duration.zero,
          );
      final PolicyPurchaseController purchaseController =
          PolicyPurchaseController(
            marketplaceRepository: MockInsuranceMarketplaceRepository(
              delay: Duration.zero,
            ),
            profileRepository: repository,
            purchaseRepository: purchaseRepository,
            productId: 'travel-worldwide-01',
          );
      await purchaseController.initialize();
      expect(purchaseController.profile?.fullName, 'Muhammad Saim Ahmad');
    },
  );
}

Future<void> _completeVerifiedNameChange(
  IdentityVerificationController controller,
) async {
  await controller.startOrResumeVerification();
  controller.updateConsent(true);
  controller.continueFromIntroduction();
  controller.submitLegalDetails(
    IdentityLegalDetails(
      fullLegalName: 'Muhammad Saim Ahmad',
      cnicNumber: _syntheticIdentityNumber(),
      dateOfBirth: DateTime(1990),
      gender: ProfileGender.preferNotToSay,
      cnicExpiryDate: DateTime.now().add(const Duration(days: 900)),
    ),
  );
  for (final (IdentityCaptureSide side, String fingerprint)
      in <(IdentityCaptureSide, String)>[
        (IdentityCaptureSide.front, 'front-name-proof'),
        (IdentityCaptureSide.back, 'back-name-proof'),
        (IdentityCaptureSide.selfie, 'selfie-name-proof'),
      ]) {
    await controller.registerCapture(_capture(side, fingerprint));
    controller.continueAfterCapture(side);
  }
  controller.confirmNameChange();
  await controller.submitVerification();
}

IdentityCaptureInput _capture(IdentityCaptureSide side, String fingerprint) {
  return IdentityCaptureInput(
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
}

String _syntheticIdentityNumber() => <String>[
  List<String>.filled(5, '1').join(),
  List<String>.filled(7, '2').join(),
  '3',
].join('-');
