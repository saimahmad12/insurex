import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/profile/application/controllers/edit_profile_controller.dart';
import 'package:insurancex/features/profile/application/controllers/identity_verification_controller.dart';
import 'package:insurancex/features/profile/application/controllers/notification_preferences_controller.dart';
import 'package:insurancex/features/profile/application/controllers/security_settings_controller.dart';
import 'package:insurancex/features/profile/data/repositories/mock_auth_session_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_notification_preferences_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:insurancex/features/profile/data/repositories/mock_security_repository.dart';
import 'package:insurancex/features/profile/domain/entities/identity_verification.dart';
import 'package:insurancex/features/profile/domain/entities/user_profile.dart';
import 'package:insurancex/features/profile/presentation/pages/change_password_page.dart';
import 'package:insurancex/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:insurancex/features/profile/presentation/pages/help_support_page.dart';
import 'package:insurancex/features/profile/presentation/pages/identity_verification_page.dart';
import 'package:insurancex/features/profile/presentation/pages/legal_placeholder_page.dart';
import 'package:insurancex/features/profile/presentation/pages/notification_settings_page.dart';
import 'package:insurancex/features/profile/presentation/pages/security_settings_page.dart';

void main() {
  testWidgets('Edit Profile locks protected fields and saves address', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final MockProfileRepository repository = MockProfileRepository(
      delay: Duration.zero,
    );
    final UserProfile profile = (await repository.getProfile())!;
    UserProfile? saved;
    int emailChangeRequests = 0;
    int mobileChangeRequests = 0;
    int identityCorrectionRequests = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: EditProfilePage(
          controller: EditProfileController(
            repository: repository,
            originalProfile: profile,
          ),
          onBack: () {},
          onSaved: (UserProfile value) {
            saved = value;
          },
          onRequestEmailChange: () {
            emailChangeRequests++;
          },
          onRequestMobileChange: () {
            mobileChangeRequests++;
          },
          onRequestIdentityCorrection: () {
            identityCorrectionRequests++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final String key in <String>[
      'edit_profile_name',
      'edit_profile_email',
      'edit_profile_mobile',
      'edit_profile_dob',
      'edit_profile_gender',
      'edit_profile_identity',
    ]) {
      final EditableText field = tester.widget<EditableText>(
        _editableField(key),
      );
      expect(field.readOnly, isTrue);
      expect(field.focusNode.canRequestFocus, isFalse);
    }
    for (final String key in <String>[
      'edit_profile_address',
      'edit_profile_city',
      'edit_profile_country',
    ]) {
      expect(
        tester.widget<EditableText>(_editableField(key)).readOnly,
        isFalse,
      );
    }
    expect(_authFieldText(tester, 'edit_profile_name'), profile.fullName);
    expect(_authFieldText(tester, 'edit_profile_identity'), '*****-*******-3');
    expect(_authFieldText(tester, 'edit_profile_email'), profile.emailAddress);
    expect(_authFieldText(tester, 'edit_profile_mobile'), profile.mobileNumber);
    final Iterable<String> renderedInputValues = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .map((EditableText field) => field.controller.text);
    expect(
      renderedInputValues.any(
        (String value) => RegExp(r'(?<!\d)\d{13}(?!\d)').hasMatch(value),
      ),
      isFalse,
    );
    expect(
      find.text(
        'Verified identity information cannot be edited directly. Contact support if a correction is required.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('request_email_change_button')));
    await tester.tap(find.byKey(const Key('request_mobile_change_button')));
    expect(emailChangeRequests, 1);
    expect(mobileChangeRequests, 1);

    final Finder dateField = _profileField('edit_profile_dob');
    final EditableText dateInput = tester.widget<EditableText>(
      _editableField('edit_profile_dob'),
    );
    expect(dateInput.readOnly, isTrue);
    expect(dateInput.focusNode.canRequestFocus, isFalse);
    await tester.tap(dateField);
    await tester.pump();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(tester.testTextInput.hasAnyClients, isFalse);

    await tester.ensureVisible(
      find.byKey(const Key('request_identity_correction_button')),
    );
    await tester.tap(
      find.byKey(const Key('request_identity_correction_button')),
    );
    expect(identityCorrectionRequests, 1);

    await tester.enterText(_profileField('edit_profile_address'), 'x');
    final Finder saveButton = find.byKey(const Key('save_profile_button'));
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Enter your residential address.'), findsOneWidget);
    expect(saved, isNull);

    await tester.enterText(
      _profileField('edit_profile_address'),
      'Apartment 12, Blue Area',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(saved?.address.residentialAddress, 'Apartment 12, Blue Area');
    expect(saved?.emailAddress, profile.emailAddress);
    expect(saved?.mobileNumber, profile.mobileNumber);
    expect(saved?.maskedIdentityNumber, profile.maskedIdentityNumber);
  });

  for (final IdentityVerificationStatus status in <IdentityVerificationStatus>[
    IdentityVerificationStatus.pending,
    IdentityVerificationStatus.rejected,
  ]) {
    testWidgets('Edit Profile locks identity fields when ${status.name}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final UserProfile base = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      final UserProfile profile = base.copyWith(
        identityVerification: IdentityVerification(
          status: status,
          maskedIdentityNumber: '*****-*******-3',
        ),
      );
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
        initialProfile: profile,
      );
      int identityCorrectionRequests = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: EditProfilePage(
            controller: EditProfileController(
              repository: repository,
              originalProfile: profile,
            ),
            onBack: () {},
            onSaved: (_) {},
            onRequestEmailChange: () {},
            onRequestMobileChange: () {},
            onRequestIdentityCorrection: () {
              identityCorrectionRequests++;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final String key in <String>[
        'edit_profile_name',
        'edit_profile_dob',
        'edit_profile_gender',
        'edit_profile_identity',
      ]) {
        final EditableText field = tester.widget<EditableText>(
          _editableField(key),
        );
        expect(field.readOnly, isTrue);
        expect(field.focusNode.canRequestFocus, isFalse);
      }
      expect(find.byType(DropdownButtonFormField<ProfileGender>), findsNothing);
      expect(
        find.byKey(const Key('request_identity_correction_button')),
        findsOneWidget,
      );
      if (status == IdentityVerificationStatus.rejected) {
        expect(find.text('Retry Verification'), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const Key('request_identity_correction_button')),
        );
        await tester.tap(
          find.byKey(const Key('request_identity_correction_button')),
        );
        expect(identityCorrectionRequests, 1);
      }
    });
  }

  testWidgets('Edit Profile failure stays on the page and preserves values', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final MockProfileRepository repository = MockProfileRepository(
      delay: Duration.zero,
      failUpdate: true,
    );
    final UserProfile profile = (await repository.getProfile())!;
    int saveSuccessCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: EditProfilePage(
          controller: EditProfileController(
            repository: repository,
            originalProfile: profile,
          ),
          onBack: () {},
          onSaved: (_) {
            saveSuccessCount++;
          },
          onRequestEmailChange: () {},
          onRequestMobileChange: () {},
          onRequestIdentityCorrection: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder saveButton = find.byKey(const Key('save_profile_button'));
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_save_error')), findsOneWidget);
    expect(saveSuccessCount, 0);
    expect(repository.updateProfileCallCount, 1);
  });

  for (final IdentityVerificationStatus status
      in IdentityVerificationStatus.values) {
    testWidgets('Identity Verification renders the ${status.name} state', (
      WidgetTester tester,
    ) async {
      final UserProfile base = (await MockProfileRepository(
        delay: Duration.zero,
      ).getProfile())!;
      final IdentityVerification verification = IdentityVerification(
        status: status,
        maskedIdentityNumber: '*****-*******-3',
        submittedAt: status == IdentityVerificationStatus.notStarted
            ? null
            : DateTime(2026, 8, 25),
        verifiedAt: status == IdentityVerificationStatus.verified
            ? DateTime(2026, 8, 26)
            : null,
        rejectionReason: status == IdentityVerificationStatus.rejected
            ? 'The submitted information could not be verified.'
            : null,
      );
      final MockProfileRepository repository = MockProfileRepository(
        delay: Duration.zero,
        initialProfile: base.copyWith(identityVerification: verification),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: IdentityVerificationPage(
            controller: IdentityVerificationController(repository: repository),
            onBack: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_identityStatusLabel(status)), findsOneWidget);
      expect(
        find.byKey(const Key('identity_status_explanation')),
        findsOneWidget,
      );
      expect(find.text('*****-*******-3'), findsOneWidget);
      if (status == IdentityVerificationStatus.notStarted ||
          status == IdentityVerificationStatus.rejected) {
        expect(
          find.byKey(const Key('start_identity_verification_button')),
          findsOneWidget,
        );
      } else {
        expect(
          find.byKey(const Key('start_identity_verification_button')),
          findsNothing,
        );
      }
    });
  }

  testWidgets('Identity Verification renders rejected and retry states', (
    WidgetTester tester,
  ) async {
    final UserProfile base = (await MockProfileRepository(
      delay: Duration.zero,
    ).getProfile())!;
    final UserProfile rejected = base.copyWith(
      identityVerification: const IdentityVerification(
        status: IdentityVerificationStatus.rejected,
        maskedIdentityNumber: '*****-*******-3',
        rejectionReason: 'The submitted information could not be verified.',
      ),
    );
    final MockProfileRepository repository = MockProfileRepository(
      delay: Duration.zero,
      initialProfile: rejected,
      verificationOutcome: IdentityVerificationStatus.pending,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: IdentityVerificationPage(
          controller: IdentityVerificationController(repository: repository),
          onBack: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verification Rejected'), findsOneWidget);
    expect(find.text('*****-*******-3'), findsOneWidget);
    expect(find.text('Retry Verification'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('start_identity_verification_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Verification Pending'), findsOneWidget);
  });

  testWidgets('Identity system back returns the latest verification state', (
    WidgetTester tester,
  ) async {
    final UserProfile base = (await MockProfileRepository(
      delay: Duration.zero,
    ).getProfile())!;
    final MockProfileRepository repository = MockProfileRepository(
      delay: Duration.zero,
      initialProfile: base.copyWith(
        identityVerification: const IdentityVerification(
          status: IdentityVerificationStatus.rejected,
          maskedIdentityNumber: '*****-*******-3',
          rejectionReason: 'The submitted information could not be verified.',
        ),
      ),
      verificationOutcome: IdentityVerificationStatus.pending,
    );
    IdentityVerification? returned;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: IdentityVerificationPage(
          controller: IdentityVerificationController(repository: repository),
          onBack: (IdentityVerification? value) {
            returned = value;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('start_identity_verification_button')),
    );
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(returned?.status, IdentityVerificationStatus.pending);
  });

  testWidgets('Security page shows settings and updates only biometric tile', (
    WidgetTester tester,
  ) async {
    final MockSecurityRepository repository = MockSecurityRepository(
      delay: Duration.zero,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SecuritySettingsPage(
          controller: SecuritySettingsController(
            repository: repository,
            authSessionRepository: MockAuthSessionRepository(
              delay: Duration.zero,
            ),
          ),
          onBack: () {},
          onChangePassword: () {},
          onPlaceholderAction: (_) {},
          onLogoutSuccess: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Two-factor authentication'), findsOneWidget);
    expect(find.textContaining('Current device'), findsOneWidget);
    final Finder biometricSwitch = find.descendant(
      of: find.byKey(const Key('biometric_login_setting')),
      matching: find.byType(Switch),
    );
    await tester.tap(biometricSwitch);
    await tester.pumpAndSettle();
    expect(repository.settingsUpdateCallCount, 1);
    expect(tester.widget<Switch>(biometricSwitch).value, isTrue);
  });

  testWidgets('Change Password validates and clears values after success', (
    WidgetTester tester,
  ) async {
    final MockSecurityRepository repository = MockSecurityRepository(
      delay: Duration.zero,
    );
    int successCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: ChangePasswordPage(
          controller: SecuritySettingsController(
            repository: repository,
            authSessionRepository: MockAuthSessionRepository(
              delay: Duration.zero,
            ),
          ),
          onBack: () {},
          onPasswordChanged: () {
            successCount++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder action = find.byKey(const Key('change_password_button'));
    await tester.tap(action);
    await tester.pump();
    expect(find.text('Enter your current password.'), findsOneWidget);

    await _enterAuthField(tester, 'current_password_field', 'Current@123');
    await _enterAuthField(tester, 'new_password_field', 'NewSecure1');
    await _enterAuthField(tester, 'confirm_password_field', 'NewSecure1');
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('change_password_success')), findsOneWidget);
    expect(repository.passwordChangeCallCount, 1);
    expect(_authFieldText(tester, 'new_password_field'), isEmpty);
    expect(successCount, 1);

    await tester.tap(action);
    await tester.pump();
    expect(successCount, 1);
  });

  testWidgets('Change Password failure remains on the page', (
    WidgetTester tester,
  ) async {
    final MockSecurityRepository repository = MockSecurityRepository(
      delay: Duration.zero,
      failPasswordChange: true,
    );
    int successCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: ChangePasswordPage(
          controller: SecuritySettingsController(
            repository: repository,
            authSessionRepository: MockAuthSessionRepository(
              delay: Duration.zero,
            ),
          ),
          onBack: () {},
          onPasswordChanged: () {
            successCount++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _enterAuthField(tester, 'current_password_field', 'Invalid@123');
    await _enterAuthField(tester, 'new_password_field', 'NewSecure1');
    await _enterAuthField(tester, 'confirm_password_field', 'NewSecure1');
    final Finder action = find.byKey(const Key('change_password_button'));
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsWidgets);
    expect(find.byKey(const Key('change_password_error')), findsOneWidget);
    expect(_authFieldText(tester, 'new_password_field'), 'NewSecure1');
    expect(repository.passwordChangeCallCount, 1);
    expect(successCount, 0);
  });

  testWidgets('Notification toggle saves one preference without page loader', (
    WidgetTester tester,
  ) async {
    final MockNotificationPreferencesRepository repository =
        MockNotificationPreferencesRepository(delay: Duration.zero);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: NotificationSettingsPage(
          controller: NotificationPreferencesController(repository: repository),
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder tile = find.byKey(
      const ValueKey<String>('notification_promotionalNotifications'),
    );
    final Finder toggle = find.descendant(
      of: tile,
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(toggle).value, isFalse);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(repository.updateCallCount, 1);
    expect(
      find.byKey(const Key('notification_preferences_loading')),
      findsNothing,
    );
    expect(tester.widget<Switch>(toggle).value, isTrue);
  });

  testWidgets('Help and legal placeholders contain required content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: HelpSupportPage(onBack: () {}, onAction: (_) {}),
      ),
    );
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('Claim Support'), findsOneWidget);
    expect(find.text('Payment Support'), findsOneWidget);
    expect(find.byKey(const Key('app_version_information')), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: LegalPlaceholderPage(
          type: LegalPlaceholderType.privacyPolicy,
          onBack: () {},
        ),
      ),
    );
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('Final legal content'), findsOneWidget);
    expect(find.textContaining('legal commitment'), findsOneWidget);
  });
}

Future<void> _enterAuthField(WidgetTester tester, String key, String value) {
  return tester.enterText(
    find.descendant(
      of: find.byKey(ValueKey<String>(key)),
      matching: find.byType(TextFormField),
    ),
    value,
  );
}

String _authFieldText(WidgetTester tester, String key) {
  return tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(ValueKey<String>(key)),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;
}

Finder _profileField(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

Finder _editableField(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(EditableText),
  );
}

String _identityStatusLabel(IdentityVerificationStatus status) {
  return switch (status) {
    IdentityVerificationStatus.notStarted => 'Not Verified',
    IdentityVerificationStatus.pending => 'Verification Pending',
    IdentityVerificationStatus.verified => 'Identity Verified',
    IdentityVerificationStatus.rejected => 'Verification Rejected',
  };
}
