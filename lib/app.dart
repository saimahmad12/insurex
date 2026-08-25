import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';

// ============================================================
// AUTH CONTROLLERS
// ============================================================
import 'features/auth/application/controllers/forgot_password_controller.dart';
import 'features/auth/application/controllers/login_controller.dart';
import 'features/auth/application/controllers/otp_verification_controller.dart';
import 'features/auth/application/controllers/reset_password_controller.dart';
import 'features/auth/application/controllers/signup_controller.dart';

// ============================================================
// AUTH REPOSITORIES
// ============================================================
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/mock_otp_verification_repository.dart';
import 'features/auth/data/repositories/mock_password_recovery_repository.dart';
import 'features/auth/data/repositories/mock_reset_password_repository.dart';
import 'features/auth/data/repositories/mock_signup_repository.dart';

// ============================================================
// AUTH PAGES
// ============================================================
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';

// ============================================================
// SPLASH
// ============================================================
import 'features/splash/presentation/pages/splash_page.dart';

// ============================================================
// CLAIMS
// ============================================================
import 'features/claims/application/controllers/file_claim_controller.dart';
import 'features/claims/data/repositories/mock_claim_image_repository.dart';
import 'features/claims/data/repositories/mock_claim_image_source.dart';
import 'features/claims/data/repositories/mock_claim_verification_repository.dart';
import 'features/claims/data/repositories/mock_file_claim_repository.dart';
import 'features/claims/domain/entities/claim_submission_result.dart';
import 'features/claims/presentation/pages/claim_submitted_page.dart';
import 'features/claims/presentation/pages/file_claim_page.dart';

// ============================================================
// DASHBOARD
// ============================================================
import 'features/dashboard/application/controllers/dashboard_controller.dart';
import 'features/dashboard/application/controllers/dashboard_navigation_controller.dart';
import 'features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'features/dashboard/presentation/pages/dashboard_navigation_shell.dart';

// ============================================================
// POLICIES
// ============================================================
import 'features/policies/application/controllers/policies_controller.dart';
import 'features/policies/application/controllers/policy_details_controller.dart';

import 'features/policies/data/repositories/mock_policies_repository.dart';
import 'features/policies/data/repositories/mock_policy_details_repository.dart';

import 'features/policies/domain/entities/insurance_policy.dart';

import 'features/policies/presentation/pages/policy_details_page.dart';

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
        // ============================================================
        // SPLASH
        // ============================================================
        AppRoutes.splash: (BuildContext context) {
          return SplashPage(
            onGetStarted: () {
              Navigator.of(context).pushNamed(AppRoutes.signup);
            },

            onLogin: () {
              Navigator.of(context).pushNamed(AppRoutes.login);
            },
          );
        },

        // ============================================================
        // LOGIN
        // ============================================================
        AppRoutes.login: (BuildContext context) {
          return LoginPage(
            controller: LoginController(repository: const MockAuthRepository()),

            onBack: () {
              Navigator.of(context).pop();
            },

            // --------------------------------------------------------
            // Successful login
            //
            // Clear previous authentication screens so pressing
            // Android back from Dashboard does not reopen Login.
            // --------------------------------------------------------
            onLoginSuccess: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard,
                (Route<dynamic> route) => false,
              );
            },

            onForgotPassword: () {
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
            },

            onSignUp: () {
              Navigator.of(context).pushNamed(AppRoutes.signup);
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
        AppRoutes.signup: (BuildContext context) {
          return SignupPage(
            controller: SignupController(
              repository: const MockSignupRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onSignupSuccess: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },

            onLoginPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },

            onGoogleSignup: () {
              _showMessage(
                context,
                'Google registration is not connected yet.',
              );
            },

            onAppleSignup: () {
              _showMessage(context, 'Apple registration is not connected yet.');
            },

            onTermsPressed: () {
              _showMessage(context, 'Terms of Service will be added later.');
            },

            onPrivacyPressed: () {
              _showMessage(context, 'Privacy Policy will be added later.');
            },
          );
        },

        // ============================================================
        // FORGOT PASSWORD
        // ============================================================
        AppRoutes.forgotPassword: (BuildContext context) {
          return ForgotPasswordPage(
            controller: ForgotPasswordController(
              repository: const MockPasswordRecoveryRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onBackToLogin: () {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (
                Route<dynamic> route,
              ) {
                return route.settings.name == AppRoutes.splash;
              });
            },

            // Pass email/mobile to OTP screen.
            onContinueToVerification: (String identity) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.otpVerification, arguments: identity);
            },
          );
        },

        // ============================================================
        // OTP VERIFICATION
        // ============================================================
        AppRoutes.otpVerification: (BuildContext context) {
          // Get email/mobile passed from Forgot Password.
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;

          final String identity = arguments is String ? arguments : '';

          return OtpVerificationPage(
            identity: identity,

            controller: OtpVerificationController(
              repository: const MockOtpVerificationRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            // OTP verified successfully.
            onVerified: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.resetPassword,
                arguments: identity,
              );
            },
          );
        },

        // ============================================================
        // RESET PASSWORD
        // ============================================================
        AppRoutes.resetPassword: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;

          final String identity = arguments is String ? arguments : '';

          return ResetPasswordPage(
            identity: identity,

            controller: ResetPasswordController(
              repository: const MockResetPasswordRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            onResetSuccess: () {
              _showMessage(context, 'Password reset successfully.');

              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (Route<dynamic> route) => false,
              );
            },

            onBackToLogin: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (Route<dynamic> route) => false,
              );
            },
          );
        },

        // ============================================================
        // DASHBOARD
        // ============================================================
        AppRoutes.dashboard: (BuildContext context) {
          return _buildDashboardNavigationShell(context);
        },

        // ============================================================
        // MY POLICIES
        // ============================================================
        AppRoutes.myPolicies: (BuildContext context) {
          return _buildDashboardNavigationShell(
            context,
            initialTab: DashboardNavigationTab.policies,
          );
        },

        // ============================================================
        // POLICY DETAILS
        // ============================================================
        AppRoutes.policyDetails: (BuildContext context) {
          // Get selected InsurancePolicy passed from
          // My Policies screen.
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;

          // ----------------------------------------------------------
          // Route safety
          //
          // Policy Details cannot work without a selected policy.
          // ----------------------------------------------------------
          if (arguments is! InsurancePolicy) {
            return Scaffold(
              backgroundColor: const Color(0xFF061027),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFFF718A),
                        size: 46,
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Policy information is unavailable.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final InsurancePolicy policy = arguments;

          return PolicyDetailsPage(
            policy: policy,

            controller: PolicyDetailsController(
              repository: const MockPolicyDetailsRepository(),
            ),

            onBack: () {
              Navigator.of(context).pop();
            },

            // --------------------------------------------------------
            // Policy Details → File a Claim
            //
            // File a Claim is the next feature.
            // For now we only show a message.
            // --------------------------------------------------------
            onActivateClaim: (InsurancePolicy selectedPolicy) {
              _openFileClaim(context, policy: selectedPolicy);
            },
          );
        },

        // ============================================================
        // FILE A CLAIM
        // ============================================================
        AppRoutes.fileClaim: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final InsurancePolicy? selectedPolicy = arguments is InsurancePolicy
              ? arguments
              : null;

          return _FileClaimRouteScope(
            initialPolicyId: selectedPolicy?.id,
            onBack: () {
              Navigator.of(context).pop();
            },
            onSubmitted: (ClaimSubmissionResult result) {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.claimSubmitted,
                arguments: result,
              );
            },
          );
        },

        // ============================================================
        // CLAIM SUBMITTED
        // ============================================================
        AppRoutes.claimSubmitted: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;

          if (arguments is! ClaimSubmissionResult) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.dashboard,
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Return to Dashboard'),
                ),
              ),
            );
          }

          return ClaimSubmittedPage(
            result: arguments,
            onTrackClaim: () {
              _showMessage(context, 'Claim tracking will be connected next.');
            },
            onViewDetails: () {
              _showMessage(context, 'Claim details will be connected next.');
            },
            onReturnToDashboard: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard,
                (Route<dynamic> route) => false,
              );
            },
          );
        },
      },
    );
  }

  static Widget _buildDashboardNavigationShell(
    BuildContext context, {
    DashboardNavigationTab initialTab = DashboardNavigationTab.home,
  }) {
    return DashboardNavigationShell(
      navigationController: DashboardNavigationController(
        initialTab: initialTab,
      ),
      dashboardController: DashboardController(
        repository: const MockDashboardRepository(),
      ),
      policiesController: PoliciesController(
        repository: const MockPoliciesRepository(),
      ),
      onFileClaim: () {
        _openFileClaim(context);
      },
      onClaimStatus: () {
        _showMessage(context, 'Claim Status screen will be created soon.');
      },
      onPayments: () {
        _showMessage(context, 'Payments screen will be created soon.');
      },
      onNotifications: () {
        _showMessage(context, 'Notifications screen will be created soon.');
      },
      onClaims: () {
        _showMessage(context, 'Claims screen will be created soon.');
      },
      onProfile: () {
        _showMessage(context, 'Profile screen will be created soon.');
      },
      onPolicySearch: () {
        _showMessage(context, 'Policy search will be added later.');
      },
      onPolicyPressed: (InsurancePolicy policy) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.policyDetails, arguments: policy);
      },
      onBuyPolicy: () {
        _showMessage(context, 'Buy New Policy screen will be added later.');
      },
    );
  }

  static void _openFileClaim(BuildContext context, {InsurancePolicy? policy}) {
    Navigator.of(context).pushNamed(AppRoutes.fileClaim, arguments: policy);
  }

  // ================================================================
  // COMMON MESSAGE
  // ================================================================
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _FileClaimRouteScope extends StatefulWidget {
  const _FileClaimRouteScope({
    required this.onBack,
    required this.onSubmitted,
    this.initialPolicyId,
  });

  final String? initialPolicyId;
  final VoidCallback onBack;
  final ValueChanged<ClaimSubmissionResult> onSubmitted;

  @override
  State<_FileClaimRouteScope> createState() => _FileClaimRouteScopeState();
}

class _FileClaimRouteScopeState extends State<_FileClaimRouteScope> {
  late final FileClaimController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FileClaimController(
      fileClaimRepository: MockFileClaimRepository(),
      verificationRepository: const MockClaimVerificationRepository(),
      imageSource: MockClaimImageSource(),
      imageRepository: const MockClaimImageRepository(),
      initialPolicyId: widget.initialPolicyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FileClaimPage(
      controller: _controller,
      onBack: widget.onBack,
      onSubmitted: widget.onSubmitted,
    );
  }
}
