import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurancex/core/theme/app_colors.dart';
import 'package:insurancex/core/theme/app_theme.dart';
import 'package:insurancex/features/auth/application/controllers/otp_verification_controller.dart';
import 'package:insurancex/features/auth/application/controllers/reset_password_controller.dart';
import 'package:insurancex/features/auth/data/repositories/mock_otp_verification_repository.dart';
import 'package:insurancex/features/auth/data/repositories/mock_reset_password_repository.dart';
import 'package:insurancex/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:insurancex/features/auth/presentation/pages/reset_password_page.dart';
import 'package:insurancex/features/auth/presentation/widgets/password_recovery_progress.dart';
import 'package:insurancex/features/auth/domain/entities/password_reset_session.dart';

void main() {
  testWidgets('shared progress renders every recovery state correctly', (
    WidgetTester tester,
  ) async {
    for (final PasswordRecoveryStep step in PasswordRecoveryStep.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: PasswordRecoveryProgress(currentStep: step)),
        ),
      );

      _expectProgress(tester, step);
    }
  });

  testWidgets(
    'OTP Verification uses the Code progress state',
        (WidgetTester tester) async {
      _useTallTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: OtpVerificationPage(
            identity: 'policyholder@example.test',
            controller: OtpVerificationController(
              repository: const MockOtpVerificationRepository(),
            ),
            onBack: () {},
            onVerified: (PasswordResetSession session) {},
          ),
        ),
      );

      expect(
        find.text('Verify Your Code'),
        findsOneWidget,
      );

      _expectProgress(
        tester,
        PasswordRecoveryStep.code,
      );
    },
  );

  testWidgets(
    'New Password uses the Password progress state',
        (WidgetTester tester) async {
      _useTallTestSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: ResetPasswordPage(
            session: const PasswordResetSession(
              identity: 'policyholder@example.test',
              resetToken: 'test-reset-token',
            ),
            controller: ResetPasswordController(
              repository: const MockResetPasswordRepository(),
            ),
            onBack: () {},
            onResetSuccess: () {},
            onBackToLogin: () {},
          ),
        ),
      );

      expect(
        find.text('Create New Password'),
        findsOneWidget,
      );

      _expectProgress(
        tester,
        PasswordRecoveryStep.password,
      );
    },
  );
}

void _expectProgress(WidgetTester tester, PasswordRecoveryStep currentStep) {
  final Finder progress = find.byKey(const Key('password_recovery_progress'));
  expect(progress, findsOneWidget);
  expect(
    find.descendant(of: progress, matching: find.text('Email')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: progress, matching: find.text('Code')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: progress, matching: find.text('Password')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: progress, matching: find.byIcon(Icons.check_rounded)),
    findsNWidgets(currentStep.index),
  );

  for (final PasswordRecoveryStep step in PasswordRecoveryStep.values) {
    final String state = step.index < currentStep.index
        ? 'completed'
        : step == currentStep
        ? 'active'
        : 'upcoming';
    expect(
      find.byKey(Key('password_recovery_step_${step.name}_$state')),
      findsOneWidget,
    );
  }

  final String emailToCodeState =
      currentStep.index > PasswordRecoveryStep.email.index
      ? 'completed'
      : 'upcoming';
  final String codeToPasswordState =
      currentStep.index > PasswordRecoveryStep.code.index
      ? 'completed'
      : 'upcoming';
  final Finder emailToCodeLine = find.byKey(
    Key('password_recovery_line_email_code_$emailToCodeState'),
  );
  final Finder codeToPasswordLine = find.byKey(
    Key('password_recovery_line_code_password_$codeToPasswordState'),
  );
  expect(emailToCodeLine, findsOneWidget);
  expect(codeToPasswordLine, findsOneWidget);
  expect(
    _lineColor(tester, emailToCodeLine),
    currentStep.index > PasswordRecoveryStep.email.index
        ? AppColors.blue.withValues(alpha: 0.8)
        : AppColors.white.withValues(alpha: 0.18),
  );
  expect(
    _lineColor(tester, codeToPasswordLine),
    currentStep.index > PasswordRecoveryStep.code.index
        ? AppColors.blue.withValues(alpha: 0.8)
        : AppColors.white.withValues(alpha: 0.18),
  );
}

Color? _lineColor(WidgetTester tester, Finder finder) =>
    (tester.widget<Container>(finder).decoration! as BoxDecoration).color;

void _useTallTestSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
