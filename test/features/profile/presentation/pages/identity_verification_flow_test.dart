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

  test('legal date and gender validation remains field-specific', () {
    final DateTime today = DateTime(2026, 9, 2);

    expect(
      IdentityVerificationValidator.validateDateOfBirth(null, today: today),
      'Select your date of birth.',
    );
    expect(
      IdentityVerificationValidator.validateDateOfBirth(
        DateTime(2026, 9, 3),
        today: today,
      ),
      'Date of birth cannot be in the future.',
    );
    expect(
      IdentityVerificationValidator.validateDateOfBirth(
        DateTime(1899, 12, 31),
        today: today,
      ),
      'Enter a realistic date of birth.',
    );
    expect(
      IdentityVerificationValidator.validateExpiryDate(null, today: today),
      'Select the CNIC expiry date.',
    );
    expect(
      IdentityVerificationValidator.validateExpiryDate(today, today: today),
      'CNIC must not be expired.',
    );
    expect(
      IdentityVerificationValidator.validateGender(null),
      'Select your gender.',
    );
  });

  testWidgets(
    'legal fields stay local, preserve consent, and progress only when valid',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final MockProfileRepository repository = await _notStartedRepository();
      final IdentityVerificationController controller =
          IdentityVerificationController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IdentityVerificationPage(
            controller: controller,
            startImmediately: true,
            onBack: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _openLegalDetails(tester);

      final Finder nameField = find.byKey(
        const Key('verification_full_name_field'),
      );
      final Finder cnicField = find.byKey(const Key('verification_cnic_field'));
      await tester.enterText(nameField, 'Synthetic Policyholder');
      await tester.enterText(cnicField, _syntheticIdentityNumber());
      await tester.ensureVisible(
        find.byKey(const Key('legal_details_continue_button')),
      );
      await tester.tap(find.byKey(const Key('legal_details_continue_button')));
      await tester.pump();

      expect(find.text('Select your date of birth.'), findsOneWidget);
      expect(find.text('Select your gender.'), findsOneWidget);
      expect(find.text('Select the CNIC expiry date.'), findsOneWidget);
      expect(find.text('Verification unavailable'), findsNothing);
      expect(controller.flowStep, IdentityVerificationFlowStep.legalDetails);
      expect(controller.consentConfirmed, isTrue);
      expect(repository.identityLoadCallCount, 1);
      expect(repository.verificationCallCount, 1);
      expect(repository.verificationSubmissionCallCount, 0);

      final DateTime now = DateTime.now();
      final DateTime selectedBirthDate = await _selectDate(
        tester,
        fieldKey: const Key('verification_date_of_birth_field'),
        day: 15,
        expectedYear: now.year - 25,
      );
      await _selectGender(tester, 'Female');
      final DateTime selectedExpiryDate = await _selectDate(
        tester,
        fieldKey: const Key('verification_cnic_expiry_field'),
        day: 16,
        expectedYear: now.year + 5,
      );

      expect(_fieldText(tester, nameField), 'Synthetic Policyholder');
      expect(_fieldText(tester, cnicField), _syntheticIdentityNumber());
      expect(controller.consentConfirmed, isTrue);
      expect(controller.flowStep, IdentityVerificationFlowStep.legalDetails);
      expect(controller.submissionStatus, IdentitySubmissionStatus.idle);
      expect(repository.identityLoadCallCount, 1);
      expect(repository.verificationCallCount, 1);
      expect(repository.verificationSubmissionCallCount, 0);
      expect(find.byKey(const Key('identity_initial_loading')), findsNothing);
      expect(find.text('Verification unavailable'), findsNothing);

      await tester.ensureVisible(
        find.byKey(const Key('verification_date_of_birth_field')),
      );
      await tester.tap(
        find.byKey(const Key('verification_date_of_birth_field')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('verification_date_of_birth_field')),
          matching: find.text(_displayDate(selectedBirthDate)),
        ),
        findsOneWidget,
      );
      expect(_fieldText(tester, nameField), 'Synthetic Policyholder');
      expect(_fieldText(tester, cnicField), _syntheticIdentityNumber());
      expect(find.text('Verification unavailable'), findsNothing);

      await tester.ensureVisible(
        find.byKey(const Key('legal_details_continue_button')),
      );
      await tester.tap(find.byKey(const Key('legal_details_continue_button')));
      await tester.pump();

      expect(controller.flowStep, IdentityVerificationFlowStep.frontCapture);
      expect(controller.legalDetails?.fullLegalName, 'Synthetic Policyholder');
      expect(controller.legalDetails?.cnicNumber, _syntheticIdentityNumber());
      expect(controller.legalDetails?.dateOfBirth, selectedBirthDate);
      expect(controller.legalDetails?.gender, ProfileGender.female);
      expect(controller.legalDetails?.cnicExpiryDate, selectedExpiryDate);
      expect(controller.consentConfirmed, isTrue);
      expect(repository.verificationSubmissionCallCount, 0);
      expect(repository.identityLoadCallCount, 1);
    },
  );

  testWidgets('invalid dates stay inline and preserve existing captures', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final MockProfileRepository repository = await _notStartedRepository();
    final IdentityUploadSession session = await repository
        .createUploadSession();
    final IdentityCaptureEvidence front = await repository.registerCapture(
      session,
      await _syntheticCapture(IdentityCaptureSide.front),
    );
    final IdentityCaptureEvidence back = await repository.registerCapture(
      session,
      await _syntheticCapture(IdentityCaptureSide.back),
    );
    final IdentityCaptureEvidence selfie = await repository.registerCapture(
      session,
      await _syntheticCapture(IdentityCaptureSide.selfie),
    );
    final DateTime today = DateTime.now();
    await repository.saveVerificationProgress(
      IdentityVerificationProgress(
        consentConfirmed: true,
        legalDetails: IdentityLegalDetails(
          fullLegalName: 'Synthetic Policyholder',
          cnicNumber: _syntheticIdentityNumber(),
          dateOfBirth: today.add(const Duration(days: 1)),
          gender: ProfileGender.female,
          cnicExpiryDate: DateTime(today.year, today.month, today.day),
        ),
        front: front,
        back: back,
        selfie: selfie,
      ),
    );
    final IdentityVerificationController controller =
        IdentityVerificationController(repository: repository);
    await controller.initialize(startImmediately: true);
    controller.reviewLegalDetails();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: IdentityVerificationPage(controller: controller, onBack: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    await _selectGender(tester, 'Male');
    await tester.ensureVisible(
      find.byKey(const Key('legal_details_continue_button')),
    );
    await tester.tap(find.byKey(const Key('legal_details_continue_button')));
    await tester.pump();

    expect(find.text('Date of birth cannot be in the future.'), findsOneWidget);
    expect(find.text('CNIC must not be expired.'), findsOneWidget);
    expect(controller.flowStep, IdentityVerificationFlowStep.legalDetails);
    expect(controller.frontCapture, same(front));
    expect(controller.backCapture, same(back));
    expect(controller.selfieCapture, same(selfie));
    expect(controller.legalDetails?.gender, ProfileGender.female);
    expect(repository.verificationSubmissionCallCount, 0);
    expect(find.text('Verification unavailable'), findsNothing);
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

Future<MockProfileRepository> _notStartedRepository() async {
  final UserProfile base = (await MockProfileRepository(
    delay: Duration.zero,
  ).getProfile())!;
  return MockProfileRepository(
    delay: Duration.zero,
    verificationOutcome: IdentityVerificationStatus.verified,
    initialProfile: base.copyWith(
      identityVerification: const IdentityVerification(
        status: IdentityVerificationStatus.notStarted,
        maskedIdentityNumber: '*****-*******-*',
      ),
    ),
  );
}

Future<void> _openLegalDetails(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('identity_consent_checkbox')));
  await tester.pump();
  await tester.tap(find.byKey(const Key('identity_intro_continue_button')));
  await tester.pump();
  expect(find.text('Enter Legal Details'), findsOneWidget);
}

Future<DateTime> _selectDate(
  WidgetTester tester, {
  required Key fieldKey,
  required int day,
  required int expectedYear,
}) async {
  await tester.ensureVisible(find.byKey(fieldKey));
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  final DateTime now = DateTime.now();
  final DateTime selected = DateTime(expectedYear, now.month, day);
  expect(
    find.descendant(
      of: find.byKey(fieldKey),
      matching: find.text(_displayDate(selected)),
    ),
    findsOneWidget,
  );
  expect(find.text('Verification unavailable'), findsNothing);
  return selected;
}

Future<void> _selectGender(WidgetTester tester, String label) async {
  final Finder field = find.byKey(const Key('verification_gender_field'));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  expect(find.text(label), findsOneWidget);
  expect(find.text('Verification unavailable'), findsNothing);
}

String _fieldText(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

String _displayDate(DateTime value) =>
    '${value.day}/${value.month}/${value.year}';

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
