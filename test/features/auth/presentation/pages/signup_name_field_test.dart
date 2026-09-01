import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/auth/application/controllers/signup_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_signup_repository.dart';
import 'package:insurancex/features/auth/presentation/pages/signup_page.dart';
import 'package:insurancex/features/profile/data/repositories/mock_profile_repository.dart';

void main() {
  testWidgets('signup explains that the account name should match the CNIC', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final MockProfileRepository profileRepository = MockProfileRepository(
      delay: Duration.zero,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SignupPage(
          controller: SignupController(
            repository: MockSignupRepository(
              initializeAccountName: (_) async {},
              delay: Duration.zero,
            ),
            identityRepository: profileRepository,
          ),
          onBack: () {},
          onContinueToIdentityVerification: () async {},
          onLoginPressed: () {},
        ),
      ),
    );

    expect(find.text('Full name as shown on your CNIC'), findsOneWidget);
    expect(
      find.text('This name will be confirmed during identity verification.'),
      findsOneWidget,
    );
  });
}
