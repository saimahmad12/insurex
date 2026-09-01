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
