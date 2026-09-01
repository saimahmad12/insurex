import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/application/validators/identity_verification_validator.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification_draft.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/profile/presentation/pages/identity_verification_page.dart';

void main() {
  test('CNIC normalization accepts raw and formatted synthetic input', () {
    const String raw = '1234512345671';
    const String formatted = '12345-1234567-1';

    expect(IdentityVerificationValidator.formatCnic(raw), formatted);
    expect(
      IdentityVerificationValidator.formatCnic(' 12345-1234567-1 '),
      formatted,
    );
    expect(IdentityVerificationValidator.validateCnic(raw), isNull);
    expect(IdentityVerificationValidator.validateCnic(formatted), isNull);
    expect(IdentityVerificationValidator.validateCnic('12345'), isNotNull);
  });

  testWidgets('introduction requires consent before legal details', (
    WidgetTester tester,
  ) async {
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

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: IdentityVerificationPage(
          controller: IdentityVerificationController(repository: repository),
          entryPoint: IdentityVerificationEntryPoint.signup,
          onBack: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('start_identity_verification_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Before you continue'), findsOneWidget);
    final GlassActionButtonFinder continueButton = GlassActionButtonFinder(
      find.byKey(const Key('identity_intro_continue_button')),
    );
    expect(continueButton.onPressed(tester), isNull);

    await tester.tap(find.byKey(const Key('identity_consent_checkbox')));
    await tester.pump();
    expect(continueButton.onPressed(tester), isNotNull);
    await tester.tap(find.byKey(const Key('identity_intro_continue_button')));
    await tester.pump();
    expect(find.text('Enter Legal Details'), findsOneWidget);
    final Finder nameField = find.byKey(
      const Key('verification_full_name_field'),
    );
    expect(tester.widget<TextField>(nameField).controller?.text, base.fullName);
    expect(find.text('Full name as shown on your CNIC'), findsOneWidget);
    expect(
      find.text(
        'Confirm that this name exactly matches your CNIC. The verified name will be used on your account, policies, claims, receipts, and official documents.',
      ),
      findsOneWidget,
    );
    final Finder cnicField = find.byKey(const Key('verification_cnic_field'));
    expect(cnicField, findsOneWidget);
    expect(tester.widget<TextField>(cnicField).obscureText, isFalse);
    expect(base.maskedIdentityNumber, startsWith('*'));

    await tester.enterText(cnicField, '12345');
    await tester.pump();
    expect(find.text('Enter CNIC in the required format.'), findsNothing);

    await tester.enterText(cnicField, '1234512345671');
    await tester.pump();
    expect(tester.widget<TextField>(cnicField).controller?.text, formattedCnic);
    expect(find.text('Enter CNIC in the required format.'), findsNothing);

    await tester.enterText(cnicField, '12345-1234567-1');
    await tester.pump();
    expect(tester.widget<TextField>(cnicField).controller?.text, formattedCnic);
  });

  testWidgets('meaningful name changes require confirmation before submission', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    final IdentityUploadSession session = await repository
        .createUploadSession();
    final List<IdentityCaptureEvidence> captures = <IdentityCaptureEvidence>[];
    for (final IdentityCaptureSide side in IdentityCaptureSide.values) {
      captures.add(
        await repository.registerCapture(
          session,
          await _syntheticCapture(side),
        ),
      );
    }
    await repository.saveVerificationProgress(
      IdentityVerificationProgress(
        consentConfirmed: true,
        legalDetails: IdentityLegalDetails(
          fullLegalName: 'Muhammad Saim Ahmad',
          cnicNumber: _syntheticIdentityNumber(),
          dateOfBirth: DateTime(1990),
          gender: ProfileGender.preferNotToSay,
          cnicExpiryDate: DateTime.now().add(const Duration(days: 900)),
        ),
        front: captures[0],
        back: captures[1],
        selfie: captures[2],
      ),
    );
    final IdentityVerificationController controller =
        IdentityVerificationController(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: IdentityVerificationPage(
          controller: controller,
          startImmediately: true,
          entryPoint: IdentityVerificationEntryPoint.signup,
          onBack: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('submit_identity_verification_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirm account name'), findsOneWidget);
    expect(find.textContaining('Signup name: Saim Ahmad'), findsOneWidget);
    expect(
      find.textContaining('Name for verification: Muhammad Saim Ahmad'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'If verification succeeds, this verified name will become your account name and will be used on policies and official documents.',
      ),
      findsOneWidget,
    );
    expect((await repository.getProfile())?.fullName, 'Saim Ahmad');

    await tester.tap(find.byKey(const Key('go_back_name_update_button')));
    await tester.pumpAndSettle();
    expect(find.text('Enter Legal Details'), findsOneWidget);
    expect((await repository.getProfile())?.fullName, 'Saim Ahmad');

    await tester.tap(find.byKey(const Key('legal_details_continue_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_name_update_button')));
    await tester.pumpAndSettle();
    final Finder submitButton = find.byKey(
      const Key('submit_identity_verification_button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Identity verified. Your account name has been updated to match your CNIC.',
      ),
      findsOneWidget,
    );
    expect(
      (await repository.refreshProfile())?.fullName,
      'Muhammad Saim Ahmad',
    );
  });
}

const String formattedCnic = '12345-1234567-1';

Future<IdentityCaptureInput> _syntheticCapture(IdentityCaptureSide side) async {
  return IdentityCaptureInput(
    side: side,
    temporaryPath: 'synthetic:${side.name}',
    fingerprint: '${side.name}-widget-proof',
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

class GlassActionButtonFinder {
  const GlassActionButtonFinder(this.finder);
  final Finder finder;

  VoidCallback? onPressed(WidgetTester tester) {
    final InkWell inkWell = tester.widget<InkWell>(
      find.descendant(of: finder, matching: find.byType(InkWell)),
    );
    return inkWell.onTap;
  }
}
