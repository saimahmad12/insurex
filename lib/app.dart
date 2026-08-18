import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';

// Controllers
import 'features/auth/application/controllers/forgot_password_controller.dart';
import 'features/auth/application/controllers/login_controller.dart';
import 'features/auth/application/controllers/otp_verification_controller.dart';
import 'features/auth/application/controllers/signup_controller.dart';

// Repositories
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/mock_otp_verification_repository.dart';
import 'features/auth/data/repositories/mock_password_recovery_repository.dart';
import 'features/auth/data/repositories/mock_signup_repository.dart';

// Auth Pages
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';

// Other Pages
import 'features/dashboard/application/controllers/dashboard_controller.dart';
import 'features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/application/controllers/reset_password_controller.dart';
import 'features/auth/data/repositories/mock_reset_password_repository.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/policies/application/controllers/policies_controller.dart';
import 'features/policies/data/repositories/mock_policies_repository.dart';
import 'features/policies/domain/entities/insurance_policy.dart';
import 'features/policies/presentation/pages/my_policies_page.dart';

class InsureXApp extends StatelessWidget {
  const InsureXApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsureX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,

      routes: <String, WidgetBuilder>{
        // ============================================================
        // SPLASH
        // ============================================================
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

        // ============================================================
        // LOGIN
        // ============================================================
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard,
                    (Route<dynamic> route) => false,
              );
            },

            onForgotPassword: () {
              Navigator.of(context).pushNamed(
                AppRoutes.forgotPassword,
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

        // ============================================================
        // SIGN UP
        // ============================================================
        AppRoutes.signup: (
            BuildContext context,
            ) {
          return SignupPage(
            controller: SignupController(
              repository:
              const MockSignupRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onSignupSuccess: () {
              Navigator.of(context)
                  .pushReplacementNamed(
                AppRoutes.login,
              );
            },

            onLoginPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(
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

        // ============================================================
        // FORGOT PASSWORD
        // ============================================================
        AppRoutes.forgotPassword: (
            BuildContext context,
            ) {
          return ForgotPasswordPage(
            controller:
            ForgotPasswordController(
              repository:
              const MockPasswordRecoveryRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onBackToLogin: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                AppRoutes.login,
                    (
                    Route<dynamic> route,
                    ) {
                  return route.settings.name ==
                      AppRoutes.splash;
                },
              );
            },

            // NEW:
            // Pass email/mobile to OTP screen.
            onContinueToVerification: (
                String identity,
                ) {
              Navigator.of(context).pushNamed(
                AppRoutes.otpVerification,
                arguments: identity,
              );
            },
          );
        },

        // ============================================================
        // OTP VERIFICATION
        // ============================================================
        AppRoutes.otpVerification: (
            BuildContext context,
            ) {
          // Get email/mobile passed from Forgot Password screen.
          final Object? arguments =
              ModalRoute.of(context)
                  ?.settings
                  .arguments;

          final String identity =
          arguments is String
              ? arguments
              : '';

          return OtpVerificationPage(
            identity: identity,

            controller:
            OtpVerificationController(
              repository:
              const MockOtpVerificationRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            // OTP verified successfully.
            // Next screen will be Create New Password.
            onVerified: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.resetPassword,
                arguments: identity,
              );
            },
          );
        },


        // ============================================================
        // RESET PASSWORD ROUTE
        // ============================================================
        AppRoutes.resetPassword: (
            BuildContext context,
            ) {
          final Object? arguments =
              ModalRoute.of(context)
                  ?.settings
                  .arguments;

          final String identity =
          arguments is String
              ? arguments
              : '';

          return ResetPasswordPage(
            identity: identity,

            controller:
            ResetPasswordController(
              repository:
              const MockResetPasswordRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onResetSuccess: () {
              _showMessage(
                context,
                'Password reset successfully.',
              );

              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                AppRoutes.login,
                    (
                    Route<dynamic> route,
                    ) =>
                false,
              );
            },

            onBackToLogin: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                AppRoutes.login,
                    (
                    Route<dynamic> route,
                    ) =>
                false,
              );
            },
          );
        },

        // ============================================================
        // DASHBOARD
        // ============================================================
        AppRoutes.dashboard: (
            BuildContext context,
            ) {
          return DashboardPage(
            controller: DashboardController(
              repository:
              const MockDashboardRepository(),
            ),

            onPolicies: () {
              Navigator.of(context).pushNamed(
                AppRoutes.myPolicies,
              );
            },

            onFileClaim: () {
              _showMessage(
                context,
                'File a Claim screen will be created soon.',
              );
            },

            onClaimStatus: () {
              _showMessage(
                context,
                'Claim Status screen will be created soon.',
              );
            },

            onPayments: () {
              _showMessage(
                context,
                'Payments screen will be created soon.',
              );
            },

            onNotifications: () {
              _showMessage(
                context,
                'Notifications screen will be created soon.',
              );
            },

            onClaims: () {
              _showMessage(
                context,
                'Claims screen will be created soon.',
              );
            },

            onProfile: () {
              _showMessage(
                context,
                'Profile screen will be created soon.',
              );
            },
          );
        },
        // ============================================================
        // MY POLICIES
        // ============================================================
        AppRoutes.myPolicies: (
            BuildContext context,
            ) {
          return MyPoliciesPage(
            controller: PoliciesController(
              repository:
              const MockPoliciesRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onSearch: () {
              _showMessage(
                context,
                'Policy search will be added later.',
              );
            },

            onPolicyPressed: (
                InsurancePolicy policy,
                ) {
              _showMessage(
                context,
                '${policy.title} details screen will be created next.',
              );
            },

            onBuyPolicy: () {
              _showMessage(
                context,
                'Buy New Policy screen will be added later.',
              );
            },
          );
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
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }
}