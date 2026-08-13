import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/controllers/login_controller.dart';
import 'features/auth/application/controllers/signup_controller.dart';
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/mock_signup_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';

class InsureXApp extends StatelessWidget {
  const InsureXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsureX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (
            BuildContext context,
            ) {
          return SplashPage(
            onGetStarted: () {
              Navigator.of(context).pushNamed(
                AppRoutes.signup,
              );
            },
            onLogin: () {
              Navigator.of(context).pushNamed(
                AppRoutes.login,
              );
            },
          );
        },

        AppRoutes.login: (
            BuildContext context,
            ) {
          return LoginPage(
            controller: LoginController(
              repository: const MockAuthRepository(),
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onLoginSuccess: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.dashboard,
              );
            },
            onForgotPassword: () {
              _showMessage(
                context,
                'Forgot-password screen will be created later.',
              );
            },
            onSignUp: () {
              Navigator.of(context).pushNamed(
                AppRoutes.signup,
              );
            },
            onGoogleLogin: () {
              _showMessage(
                context,
                'Google authentication is not connected yet.',
              );
            },
            onAppleLogin: () {
              _showMessage(
                context,
                'Apple authentication is not connected yet.',
              );
            },
            onBiometricLogin: () {
              _showMessage(
                context,
                'Biometric authentication is not connected yet.',
              );
            },
          );
        },

        AppRoutes.signup: (
            BuildContext context,
            ) {
          return SignupPage(
            controller: SignupController(
              repository: const MockSignupRepository(),
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onSignupSuccess: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.login,
              );
            },
            onLoginPressed: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.login,
              );
            },
            onGoogleSignup: () {
              _showMessage(
                context,
                'Google registration is not connected yet.',
              );
            },
            onAppleSignup: () {
              _showMessage(
                context,
                'Apple registration is not connected yet.',
              );
            },
            onTermsPressed: () {
              _showMessage(
                context,
                'Terms of Service will be added later.',
              );
            },
            onPrivacyPressed: () {
              _showMessage(
                context,
                'Privacy Policy will be added later.',
              );
            },
          );
        },

        AppRoutes.dashboard: (
            BuildContext context,
            ) {
          return const DashboardPlaceholderPage();
        },
      },
    );
  }

  static void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}