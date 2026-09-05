import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/app.dart';
import 'package:insurancex/core/navigation/app_routes.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/auth/application/controllers/login_controller.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/auth/domain/entities/account_role.dart';
import 'package:insurancex/features/auth/presentation/pages/login_page.dart';
import 'package:insurancex/features/auth/presentation/pages/signup_page.dart';
import 'package:insurancex/features/auth/presentation/widgets/account_role_selector.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';

void main() {
  testWidgets('Login displays both roles and selects Insurance Company', (
    WidgetTester tester,
  ) async {
    final LoginController controller = LoginController(
      repository: const MockAuthRepository(),
    );
    AccountRole? selectedRole;
    await _pumpAuthPage(
      tester,
      LoginPage(
        controller: controller,
        onBack: () {},
        onLoginSuccess: () {},
        onRoleSelected: (AccountRole role) {
          selectedRole = role;
        },
      ),
    );

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Insurance Company'), findsOneWidget);
    expect(
      tester
          .widget<AccountRoleSelector>(find.byType(AccountRoleSelector))
          .selectedRole,
      AccountRole.customer,
    );

    await tester.tap(find.byKey(const ValueKey<String>('account_role_seller')));
    await tester.pump();

    expect(selectedRole, AccountRole.seller);
  });

  testWidgets('Signup defaults to Customer and keeps customer fields', (
    WidgetTester tester,
  ) async {
    final MockProfileRepository profileRepository = MockProfileRepository(
      delay: Duration.zero,
    );
    final SignupController controller = SignupController(
      repository: MockSignupRepository(
        initializeAccountName: (_) async {},
        delay: Duration.zero,
      ),
      identityRepository: profileRepository,
    );
    AccountRole? selectedRole;
    await _pumpAuthPage(
      tester,
      SignupPage(
        controller: controller,
        onBack: () {},
        onContinueToIdentityVerification: () async {},
        onLoginPressed: () {},
        onRoleSelected: (AccountRole role) {
          selectedRole = role;
        },
      ),
    );

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Insurance Company'), findsOneWidget);
    expect(find.text('Full name as shown on your CNIC'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('account_role_seller')));
    await tester.pump();

    expect(selectedRole, AccountRole.seller);
  });

  testWidgets('role selector switches between customer and seller Login', (
    WidgetTester tester,
  ) async {
    await _pumpAuthPage(tester, const InsureXApp());
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).last,
    );
    unawaited(navigator.pushNamed(AppRoutes.login));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('account_role_seller')));
    await tester.pumpAndSettle();
    expect(find.text('Company Portal'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('account_role_customer')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('existing Customer Login remains functional', (
    WidgetTester tester,
  ) async {
    int loginSuccessCount = 0;
    await _pumpAuthPage(
      tester,
      LoginPage(
        controller: LoginController(repository: const MockAuthRepository()),
        onBack: () {},
        onLoginSuccess: () {
          loginSuccessCount++;
        },
      ),
    );

    await tester.enterText(
      _editableField('login_identity_field'),
      'customer@example.test',
    );
    await tester.enterText(_editableField('login_password_field'), 'password');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(loginSuccessCount, 1);
  });
}

Future<void> _pumpAuthPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: page));
  await tester.pump();
}

Finder _editableField(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);
