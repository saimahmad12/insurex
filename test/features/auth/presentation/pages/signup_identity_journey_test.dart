import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/auth/presentation/pages/signup_page.dart';
import 'package:insurancex/features/dashboard/presentation/pages/dashboard_navigation_shell.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/presentation/pages/identity_verification_page.dart';

void main() {
  testWidgets('valid account details open the canonical verification intro', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    unawaited(navigator.pushNamed(AppRoutes.signup));
    await tester.pumpAndSettle();

    await _enterValidAccountDetails(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byKey(const Key('signup_continue_button')));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Identity Verification'), findsOneWidget);
    expect(find.text('Before you continue'), findsOneWidget);
    final Finder consent = find.byKey(const Key('identity_consent_checkbox'));
    expect(consent, findsOneWidget);
    expect(tester.widget<CheckboxListTile>(consent).value, isFalse);
    expect(find.byType(DashboardNavigationShell), findsNothing);
  });

  testWidgets(
    'verification popup fields retain the route controller and legal form',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const InsureXApp());
      final NavigatorState navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed(AppRoutes.signup));
      await tester.pumpAndSettle();
      await _enterValidAccountDetails(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.byKey(const Key('signup_continue_button')));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('identity_consent_checkbox')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('identity_intro_continue_button')));
      await tester.pump();

      expect(find.text('Enter Legal Details'), findsOneWidget);
      final IdentityVerificationController originalController = tester
          .widget<IdentityVerificationPage>(
            find.byType(IdentityVerificationPage),
          )
          .controller;
      final Finder cnicField = find.byKey(const Key('verification_cnic_field'));
      await tester.enterText(cnicField, _syntheticIdentityNumber());
      final DateTime now = DateTime.now();

      final DateTime birthDate = await _selectVerificationDate(
        tester,
        fieldKey: const Key('verification_date_of_birth_field'),
        day: 15,
        year: now.year - 25,
      );
      _expectSameVerificationController(tester, originalController);
      expect(_fieldText(tester, 'verification_full_name_field'), 'Saim Ahmad');
      expect(
        _fieldText(tester, 'verification_cnic_field'),
        _syntheticIdentityNumber(),
      );

      await _selectVerificationGender(tester, 'Female');
      _expectSameVerificationController(tester, originalController);
      expect(
        find.descendant(
          of: find.byKey(const Key('verification_date_of_birth_field')),
          matching: find.text(_displayDate(birthDate)),
        ),
        findsOneWidget,
      );

      final DateTime expiryDate = await _selectVerificationDate(
        tester,
        fieldKey: const Key('verification_cnic_expiry_field'),
        day: 16,
        year: now.year + 5,
      );
      _expectSameVerificationController(tester, originalController);
      expect(find.text('Female'), findsOneWidget);
      expect(originalController.consentConfirmed, isTrue);
      expect(
        originalController.flowStep,
        IdentityVerificationFlowStep.legalDetails,
      );
      expect(
        originalController.verification?.status,
        IdentityVerificationStatus.capturing,
      );
      expect(
        originalController.submissionStatus,
        IdentitySubmissionStatus.idle,
      );
      expect(find.byKey(const Key('identity_initial_loading')), findsNothing);
      expect(find.text('Verification unavailable'), findsNothing);

      await tester.ensureVisible(
        find.byKey(const Key('verification_cnic_expiry_field')),
      );
      await tester.tap(find.byKey(const Key('verification_cnic_expiry_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      _expectSameVerificationController(tester, originalController);
      expect(
        find.descendant(
          of: find.byKey(const Key('verification_cnic_expiry_field')),
          matching: find.text(_displayDate(expiryDate)),
        ),
        findsOneWidget,
      );
      expect(find.text('Verification unavailable'), findsNothing);
    },
  );

  testWidgets('invalid or duplicate Continue actions do not open extra flows', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final MockProfileRepository profileRepository = MockProfileRepository(
      delay: Duration.zero,
    );
    final MockSignupRepository repository = MockSignupRepository(
      initializeAccountName: profileRepository.initializeUnverifiedAccountName,
      delay: Duration.zero,
    );
    int verificationOpenCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SignupPage(
          controller: SignupController(
            repository: repository,
            identityRepository: profileRepository,
          ),
          onBack: () {},
          onContinueToIdentityVerification: () async {
            verificationOpenCount++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
          },
          onLoginPressed: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('signup_continue_button')));
    await tester.pump();
    expect(verificationOpenCount, 0);
    expect(repository.prepareCallCount, 0);

    await _enterValidAccountDetails(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byKey(const Key('signup_continue_button')));
    await tester.tap(find.byKey(const Key('signup_continue_button')));
    await tester.pumpAndSettle();

    expect(verificationOpenCount, 1);
    expect(repository.prepareCallCount, 1);
    expect(_fieldText(tester, 'signup_full_name_field'), 'Saim Ahmad');
  });
}

Future<void> _enterValidAccountDetails(WidgetTester tester) async {
  await tester.enterText(
    _editableField('signup_full_name_field'),
    'Saim Ahmad',
  );
  await tester.enterText(
    _editableField('signup_email_field'),
    'policyholder@example.test',
  );
  await tester.enterText(
    _editableField('signup_mobile_field'),
    '+923001234567',
  );
  await tester.enterText(
    _editableField('signup_password_field'),
    'StrongPass1',
  );
  await tester.enterText(
    _editableField('signup_confirm_password_field'),
    'StrongPass1',
  );
}

Finder _editableField(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

String _fieldText(WidgetTester tester, String key) {
  return tester.widget<EditableText>(_editableField(key)).controller.text;
}

Future<DateTime> _selectVerificationDate(
  WidgetTester tester, {
  required Key fieldKey,
  required int day,
  required int year,
}) async {
  await tester.ensureVisible(find.byKey(fieldKey));
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  final DateTime selected = DateTime(year, DateTime.now().month, day);
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

Future<void> _selectVerificationGender(
  WidgetTester tester,
  String label,
) async {
  final Finder field = find.byKey(const Key('verification_gender_field'));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  expect(find.text('Verification unavailable'), findsNothing);
}

void _expectSameVerificationController(
  WidgetTester tester,
  IdentityVerificationController expected,
) {
  final IdentityVerificationController current = tester
      .widget<IdentityVerificationPage>(find.byType(IdentityVerificationPage))
      .controller;
  expect(current, same(expected));
  expect(find.text('Enter Legal Details'), findsOneWidget);
}

String _syntheticIdentityNumber() => <String>[
  List<String>.filled(5, '1').join(),
  List<String>.filled(7, '2').join(),
  '3',
].join('-');

String _displayDate(DateTime value) =>
    '${value.day}/${value.month}/${value.year}';
