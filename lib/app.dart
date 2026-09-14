import 'dart:async';

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
import 'features/auth/application/controllers/seller_login_controller.dart';
import 'features/auth/application/controllers/seller_registration_controller.dart';
import 'features/auth/application/controllers/signup_controller.dart';
import 'features/auth/application/validators/seller_auth_validator.dart';

// ============================================================
// AUTH REPOSITORIES
// ============================================================
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/mock_otp_verification_repository.dart';
import 'features/auth/data/repositories/mock_password_recovery_repository.dart';
import 'features/auth/data/repositories/mock_reset_password_repository.dart';
import 'features/auth/data/repositories/mock_seller_auth_repository.dart';
import 'features/auth/data/repositories/mock_seller_registration_repository.dart';
import 'features/auth/data/repositories/mock_signup_repository.dart';

// ============================================================
// AUTH DOMAIN
// ============================================================
import 'features/auth/domain/entities/account_role.dart';
import 'features/auth/domain/entities/seller_authentication.dart';
import 'features/auth/domain/entities/seller_registration.dart';
import 'features/auth/domain/repositories/seller_auth_repository.dart';
import 'features/auth/domain/repositories/seller_registration_repository.dart';

// ============================================================
// AUTH PAGES
// ============================================================
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/seller_account_status_page.dart';
import 'features/auth/presentation/pages/seller_login_page.dart';
import 'features/auth/presentation/pages/seller_registration_page.dart';
import 'features/auth/presentation/pages/seller_registration_submitted_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';

// ============================================================
// SPLASH
// ============================================================
import 'features/splash/presentation/pages/splash_page.dart';

// ============================================================
// CLAIMS
// ============================================================
import 'features/claims/application/controllers/file_claim_controller.dart';
import 'features/claims/application/controllers/claim_status_controller.dart';
import 'features/claims/application/controllers/my_claims_controller.dart';
import 'features/claims/data/repositories/mock_claim_image_repository.dart';
import 'features/claims/data/repositories/mock_claim_image_source.dart';
import 'features/claims/data/repositories/mock_claim_verification_repository.dart';
import 'features/claims/data/repositories/mock_file_claim_repository.dart';
import 'features/claims/data/repositories/mock_claim_status_repository.dart';
import 'features/claims/domain/entities/claim_submission_result.dart';
import 'features/claims/domain/entities/insurance_claim.dart';
import 'features/claims/domain/repositories/claim_status_repository.dart';
import 'features/claims/presentation/pages/claim_status_page.dart';
import 'features/claims/presentation/pages/claim_submitted_page.dart';
import 'features/claims/presentation/pages/file_claim_page.dart';

// ============================================================
// PAYMENTS
// ============================================================
import 'features/payments/application/controllers/claim_payout_controller.dart';
import 'features/payments/application/controllers/payments_history_controller.dart';
import 'features/payments/data/repositories/mock_claim_payout_repository.dart';
import 'features/payments/domain/repositories/claim_payout_repository.dart';
import 'features/payments/presentation/pages/claim_payout_flow_page.dart';
import 'features/payments/presentation/pages/payments_history_page.dart';

// ============================================================
// PROFILE
// ============================================================
import 'features/profile/application/controllers/edit_profile_controller.dart';
import 'features/profile/application/controllers/identity_verification_controller.dart';
import 'features/profile/application/controllers/notification_preferences_controller.dart';
import 'features/profile/application/controllers/profile_controller.dart';
import 'features/profile/application/controllers/saved_payout_methods_controller.dart';
import 'features/profile/application/controllers/security_settings_controller.dart';
import 'features/profile/data/repositories/mock_auth_session_repository.dart';
import 'features/profile/data/repositories/mock_notification_preferences_repository.dart';
import 'features/profile/data/repositories/mock_profile_repository.dart';
import 'features/profile/data/repositories/mock_security_repository.dart';
import 'features/profile/domain/entities/identity_verification.dart';
import 'features/profile/domain/entities/user_profile.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/help_support_page.dart';
import 'features/profile/presentation/pages/identity_verification_page.dart';
import 'features/profile/presentation/pages/legal_placeholder_page.dart';
import 'features/profile/presentation/pages/notification_settings_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/saved_payout_methods_page.dart';
import 'features/profile/presentation/pages/security_settings_page.dart';

// ============================================================
// DASHBOARD
// ============================================================
import 'features/dashboard/application/controllers/dashboard_controller.dart';
import 'features/dashboard/application/controllers/dashboard_navigation_controller.dart';
import 'features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'features/dashboard/presentation/pages/dashboard_navigation_shell.dart';

// ============================================================
// SELLER DASHBOARD
// ============================================================
import 'features/seller_dashboard/application/controllers/seller_dashboard_controller.dart';
import 'features/seller_dashboard/application/controllers/seller_dashboard_navigation_controller.dart';
import 'features/seller_dashboard/data/repositories/mock_seller_dashboard_repository.dart';
import 'features/seller_dashboard/domain/entities/seller_dashboard.dart';
import 'features/seller_dashboard/domain/repositories/seller_dashboard_repository.dart';
import 'features/seller_dashboard/presentation/pages/seller_dashboard_navigation_shell.dart';
import 'features/seller_dashboard/presentation/pages/seller_dashboard_page.dart';

// ============================================================
// POLICIES
// ============================================================
import 'features/policies/application/controllers/policies_controller.dart';
import 'features/policies/application/controllers/policy_details_controller.dart';

import 'features/policies/data/repositories/mock_policies_repository.dart';
import 'features/policies/data/repositories/mock_policy_details_repository.dart';

import 'features/policies/domain/entities/insurance_policy.dart';

import 'features/policies/presentation/pages/policy_details_page.dart';

// ============================================================
// INSURANCE MARKETPLACE & POLICY PURCHASE
// ============================================================
import 'features/insurance_marketplace/application/controllers/insurance_marketplace_controller.dart';
import 'features/insurance_marketplace/application/controllers/insurance_product_controller.dart';
import 'features/insurance_marketplace/data/repositories/mock_insurance_marketplace_repository.dart';
import 'features/insurance_marketplace/domain/entities/insurance_product.dart';
import 'features/insurance_marketplace/domain/repositories/insurance_marketplace_repository.dart';
import 'features/insurance_marketplace/presentation/pages/insurance_comparison_page.dart';
import 'features/insurance_marketplace/presentation/pages/insurance_marketplace_page.dart';
import 'features/insurance_marketplace/presentation/pages/insurance_product_details_page.dart';
import 'features/policy_purchase/application/controllers/policy_application_controller.dart';
import 'features/policy_purchase/application/controllers/policy_purchase_controller.dart';
import 'features/policy_purchase/application/controllers/policy_quote_controller.dart';
import 'features/policy_purchase/application/controllers/premium_payment_controller.dart';
import 'features/policy_purchase/data/repositories/mock_policy_application_repository.dart';
import 'features/policy_purchase/data/repositories/mock_policy_purchase_repository.dart';
import 'features/policy_purchase/data/repositories/mock_premium_payment_repository.dart';
import 'features/policy_purchase/domain/entities/premium_payment.dart';
import 'features/policy_purchase/domain/repositories/policy_application_repository.dart';
import 'features/policy_purchase/domain/repositories/policy_purchase_repository.dart';
import 'features/policy_purchase/domain/repositories/premium_payment_repository.dart';
import 'features/policy_purchase/presentation/pages/policy_purchase_page.dart';
import 'features/policy_purchase/presentation/pages/premium_payment_receipt_page.dart';

class InsureXApp extends StatefulWidget {
  const InsureXApp({
    this.initialVerificationStatus = IdentityVerificationStatus.notStarted,
    this.sellerAuthRepository,
    this.sellerDashboardRepository,
    this.sellerRegistrationRepository,
    super.key,
  });

  final IdentityVerificationStatus initialVerificationStatus;
  final SellerAuthRepository? sellerAuthRepository;
  final SellerDashboardRepository? sellerDashboardRepository;
  final SellerRegistrationRepository? sellerRegistrationRepository;

  @override
  State<InsureXApp> createState() => _InsureXAppState();
}

class _InsureXAppState extends State<InsureXApp> {
  late final MockClaimStatusRepository _claimsRepository;
  late final MockClaimPayoutRepository _payoutRepository;
  late final MockProfileRepository _profileRepository;
  late final MockNotificationPreferencesRepository
  _notificationPreferencesRepository;
  late final MockSecurityRepository _securityRepository;
  late final MockAuthSessionRepository _authSessionRepository;
  late final MockPoliciesRepository _policiesRepository;
  late final MockInsuranceMarketplaceRepository _marketplaceRepository;
  late final MockPolicyPurchaseRepository _policyPurchaseRepository;
  late final MockPolicyApplicationRepository _policyApplicationRepository;
  late final MockPremiumPaymentRepository _premiumPaymentRepository;
  late final SellerAuthRepository _sellerAuthRepository;
  late final SellerDashboardRepository _sellerDashboardRepository;
  late final SellerRegistrationRepository _sellerRegistrationRepository;

  @override
  void initState() {
    super.initState();
    _claimsRepository = MockClaimStatusRepository();
    _payoutRepository = MockClaimPayoutRepository(
      claimsRepository: _claimsRepository,
    );
    _profileRepository = MockProfileRepository(
      initialVerificationStatus: widget.initialVerificationStatus,
      verificationOutcome: IdentityVerificationStatus.verified,
    );
    _notificationPreferencesRepository =
        MockNotificationPreferencesRepository();
    _securityRepository = MockSecurityRepository();
    _authSessionRepository = MockAuthSessionRepository();
    _policiesRepository = MockPoliciesRepository();
    _marketplaceRepository = MockInsuranceMarketplaceRepository();
    _policyPurchaseRepository = MockPolicyPurchaseRepository(
      identityRepository: _profileRepository,
      policiesRepository: _policiesRepository,
    );
    _policyApplicationRepository = MockPolicyApplicationRepository();
    _premiumPaymentRepository = MockPremiumPaymentRepository();
    _sellerAuthRepository =
        widget.sellerAuthRepository ?? MockSellerAuthRepository();
    _sellerDashboardRepository =
        widget.sellerDashboardRepository ?? MockSellerDashboardRepository();
    _sellerRegistrationRepository =
        widget.sellerRegistrationRepository ??
        MockSellerRegistrationRepository();
  }

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

            onRoleSelected: (AccountRole role) {
              if (role == AccountRole.seller) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.sellerLogin);
              }
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
          final SignupController signupController = SignupController(
            repository: MockSignupRepository(
              initializeAccountName:
                  _profileRepository.initializeUnverifiedAccountName,
            ),
            identityRepository: _profileRepository,
          );
          return SignupPage(
            controller: signupController,

            onBack: () {
              Navigator.of(context).pop();
            },

            onContinueToIdentityVerification: () async {
              final Object? result = await Navigator.of(context).pushNamed(
                AppRoutes.identityVerification,
                arguments: IdentityVerificationEntryPoint.signup,
              );
              if (result is! IdentityVerification) {
                return;
              }
              final bool completed = await signupController
                  .completeVerifiedSignup();
              if (completed && context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.dashboard,
                  (Route<dynamic> route) => false,
                );
              }
            },

            onRoleSelected: (AccountRole role) {
              if (role == AccountRole.seller) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.sellerSignup);
              }
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
        // SELLER REGISTRATION
        // ============================================================
        AppRoutes.sellerSignup: (BuildContext context) {
          return SellerRegistrationPage(
            controller: SellerRegistrationController(
              repository: _sellerRegistrationRepository,
              validator: const SellerAuthValidator(),
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onRoleSelected: (AccountRole role) {
              if (role == AccountRole.customer) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
              }
            },
            onSubmitted: (SellerRegistrationResult result) {
              Navigator.of(context).pushNamed(
                AppRoutes.sellerRegistrationSubmitted,
                arguments: result,
              );
            },
            onLoginPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.sellerLogin);
            },
            onTermsPressed: () {
              _showMessage(context, 'Terms of Service will be added later.');
            },
            onPrivacyPressed: () {
              _showMessage(context, 'Privacy Policy will be added later.');
            },
          );
        },

        AppRoutes.sellerRegistrationSubmitted: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final SellerRegistrationResult result =
              arguments is SellerRegistrationResult
              ? arguments
              : const SellerRegistrationResult(
                  status: SellerRegistrationStatus.pendingApproval,
                );
          return SellerRegistrationSubmittedPage(
            result: result,
            onBack: () {
              Navigator.of(context).pop();
            },
            onReturnToLogin: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.sellerLogin,
                (Route<dynamic> route) => false,
              );
            },
            onContactSupport: () {
              _showMessage(
                context,
                'Seller support will be connected through the secure support channel.',
              );
            },
          );
        },

        // ============================================================
        // SELLER LOGIN AND ACCOUNT STATUS
        // ============================================================
        AppRoutes.sellerLogin: (BuildContext context) {
          return SellerLoginPage(
            controller: SellerLoginController(
              repository: _sellerAuthRepository,
              validator: const SellerAuthValidator(),
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onRoleSelected: (AccountRole role) {
              if (role == AccountRole.customer) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              }
            },
            onLoginResolved: (SellerAuthenticationResult result) {
              final SellerAccount account = result.account!;
              if (account.registrationStatus ==
                  SellerRegistrationStatus.approved) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.sellerDashboard,
                  (Route<dynamic> route) => false,
                  arguments: account,
                );
                return;
              }
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.sellerAccountStatus, arguments: account);
            },
            onForgotPassword: () {
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
            },
            onSignupPressed: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.sellerSignup);
            },
          );
        },

        AppRoutes.sellerAccountStatus: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final SellerAccount account = arguments is SellerAccount
              ? arguments
              : const SellerAccount(
                  companyName: 'Insurance Company',
                  businessEmail: '',
                  authoritativeRole: AccountRole.seller,
                  registrationStatus: SellerRegistrationStatus.technicalFailure,
                );
          return SellerAccountStatusPage(
            account: account,
            onBack: () {
              Navigator.of(context).pop();
            },
            onRetryRegistration: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.sellerSignup);
            },
            onContactSupport: () {
              _showMessage(
                context,
                'Seller support will be connected through the secure support channel.',
              );
            },
          );
        },

        AppRoutes.sellerDashboard: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final SellerAccount? authenticatedAccount = arguments is SellerAccount
              ? arguments
              : null;
          final SellerDashboardAccount? dashboardAccount =
              authenticatedAccount == null
              ? null
              : SellerDashboardAccount(
                  companyName: authenticatedAccount.companyName,
                  businessEmail: authenticatedAccount.businessEmail,
                  status:
                      authenticatedAccount.authoritativeRole ==
                              AccountRole.seller &&
                          authenticatedAccount.registrationStatus ==
                              SellerRegistrationStatus.approved
                      ? SellerDashboardAccountStatus.approved
                      : SellerDashboardAccountStatus.notApproved,
                );
          return _SellerDashboardRouteScope(
            account: dashboardAccount,
            repository: _sellerDashboardRepository,
            onNotifications: () {
              _showMessage(
                context,
                'Seller notifications will be available in the next module.',
              );
            },
            onFeatureUnavailable: () {
              _showMessage(
                context,
                'This feature will be available in the next module.',
              );
            },
            onReturnToLogin: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.sellerLogin,
                (Route<dynamic> route) => false,
              );
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
        // MY CLAIMS
        // ============================================================
        AppRoutes.myClaims: (BuildContext context) {
          return _buildDashboardNavigationShell(
            context,
            initialTab: DashboardNavigationTab.claims,
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
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1976D2),
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
                          color: Colors.black87,
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
        AppRoutes.insuranceMarketplace: (BuildContext context) {
          return _InsuranceMarketplaceRouteScope(
            repository: _marketplaceRepository,
            onBack: () => Navigator.of(context).pop(),
            onProductPressed:
                (
                  InsuranceMarketplaceController marketplaceController,
                  InsuranceProduct product,
                ) async {
                  final Object? result = await Navigator.of(context).pushNamed(
                    AppRoutes.insuranceProductDetails,
                    arguments: product.id,
                  );
                  if (result is _ProductDetailsAction) {
                    marketplaceController.toggleComparison(result.productId);
                  } else if (result is _MarketplaceExit && context.mounted) {
                    Navigator.of(context).pop(result);
                  }
                },
            onCompare: (List<InsuranceProduct> products) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.insuranceComparison, arguments: products);
            },
          );
        },

        AppRoutes.insuranceProductDetails: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final String productId = arguments is String ? arguments : '';
          return _InsuranceProductDetailsRouteScope(
            productId: productId,
            repository: _marketplaceRepository,
            onBack: () => Navigator.of(context).pop(),
            onBuyNow: (InsuranceProduct product) async {
              final Object? result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.policyPurchase, arguments: product.id);
              if (result is _MarketplaceExit && context.mounted) {
                Navigator.of(context).pop(result);
              }
            },
            onCompare: (InsuranceProduct product) {
              Navigator.of(
                context,
              ).pop(_ProductDetailsAction.compare(product.id));
            },
            onContactSupport: () {
              _showMessage(
                context,
                'Marketplace support will be connected to the secure backend.',
              );
            },
          );
        },

        AppRoutes.insuranceComparison: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final List<InsuranceProduct> products =
              arguments is List<InsuranceProduct>
              ? arguments
              : const <InsuranceProduct>[];
          return InsuranceComparisonPage(
            products: products,
            onBack: () => Navigator.of(context).pop(),
            onProductPressed: (InsuranceProduct product) {
              Navigator.of(context).pushNamed(
                AppRoutes.insuranceProductDetails,
                arguments: product.id,
              );
            },
          );
        },

        AppRoutes.policyPurchase: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final String productId = arguments is String ? arguments : '';
          return _PolicyPurchaseRouteScope(
            productId: productId,
            marketplaceRepository: _marketplaceRepository,
            profileRepository: _profileRepository,
            purchaseRepository: _policyPurchaseRepository,
            applicationRepository: _policyApplicationRepository,
            paymentRepository: _premiumPaymentRepository,
            onBack: () => Navigator.of(context).pop(),
            onVerifyIdentity: () async {
              final Object? result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.purchaseIdentityVerification);
              return result is IdentityVerification ? result : null;
            },
            onViewPolicy: (InsurancePolicy policy) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.policyDetails, arguments: policy);
            },
            onViewPaymentReceipt: (PremiumPayment payment) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.premiumPaymentReceipt, arguments: payment);
            },
            onMyPolicies: () {
              Navigator.of(context).pop(_MarketplaceExit.myPolicies);
            },
            onDashboard: () {
              Navigator.of(context).pop(_MarketplaceExit.dashboard);
            },
            onDownloadDocument: () {
              _showMessage(
                context,
                'Secure policy-document download will be connected later.',
              );
            },
          );
        },

        AppRoutes.premiumPaymentReceipt: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is! PremiumPayment) {
            return const SizedBox.shrink();
          }
          return PremiumPaymentReceiptPage(
            payment: arguments,
            onBack: () => Navigator.of(context).pop(),
          );
        },

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
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.claimStatus, arguments: arguments.claimId);
            },
            onReturnToDashboard: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard,
                (Route<dynamic> route) => false,
              );
            },
          );
        },

        // ============================================================
        // CLAIM STATUS
        // ============================================================
        AppRoutes.claimStatus: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          final InsuranceClaim? initialClaim = arguments is InsuranceClaim
              ? arguments
              : null;
          final String? claimId = switch (arguments) {
            String value => value,
            ClaimSubmissionResult result => result.claimId,
            InsuranceClaim claim => claim.id,
            _ => null,
          };
          final bool invalidArgument =
              arguments != null &&
              arguments is! String &&
              arguments is! ClaimSubmissionResult &&
              arguments is! InsuranceClaim;

          return _ClaimStatusRouteScope(
            claimId: claimId,
            initialClaim: initialClaim,
            invalidArgument: invalidArgument,
            claimsRepository: _claimsRepository,
            payoutRepository: _payoutRepository,
            onBack: () {
              Navigator.of(context).pop();
            },
            onFileClaim: () {
              _openFileClaim(context);
            },
            onContextualAction:
                (ClaimStatusAction action, InsuranceClaim? claim) async {
                  if (_isPayoutAction(action) && claim != null) {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.claimPayout, arguments: claim.id);
                    return;
                  }
                  _showMessage(context, _claimStatusActionMessage(action));
                },
          );
        },

        // ============================================================
        // CLAIM PAYOUT
        // ============================================================
        AppRoutes.claimPayout: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is! String || arguments.isEmpty) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Payment information is unavailable.'),
                ),
              ),
            );
          }

          return ClaimPayoutFlowPage(
            controller: ClaimPayoutController(
              claimId: arguments,
              claimsRepository: _claimsRepository,
              payoutRepository: _payoutRepository,
            ),
            onClose: () {
              Navigator.of(context).pop();
            },
            onReturnToClaimStatus: () {
              _returnToClaimStatus(context, arguments);
            },
            onReturnToMyClaims: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.myClaims,
                (Route<dynamic> route) => false,
              );
            },
            onPlaceholderAction: (String action) {
              _showMessage(context, '$action will be connected next.');
            },
          );
        },

        // ============================================================
        // PAYMENTS HISTORY
        // ============================================================
        AppRoutes.paymentsHistory: (BuildContext context) {
          return PaymentsHistoryPage(
            controller: PaymentsHistoryController(
              repository: _payoutRepository,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onPayoutPressed: (payout) {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.claimPayout, arguments: payout.claimId);
            },
          );
        },

        // ============================================================
        // PROFILE DETAILS
        // ============================================================
        AppRoutes.editProfile: (BuildContext context) {
          final Object? arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is! UserProfile) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Profile information is unavailable.'),
                ),
              ),
            );
          }
          return EditProfilePage(
            controller: EditProfileController(
              repository: _profileRepository,
              originalProfile: arguments,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onSaved: (UserProfile updated) {
              Navigator.of(context).pop(updated);
            },
            onRequestEmailChange: () {
              _showMessage(
                context,
                'Email changes require verification and will be available after backend integration.',
              );
            },
            onRequestMobileChange: () {
              _showMessage(
                context,
                'Mobile number changes require OTP verification and will be available after backend integration.',
              );
            },
            onRequestIdentityCorrection: () async {
              final IdentityVerificationStatus status =
                  arguments.identityVerification.status;
              if (status == IdentityVerificationStatus.notStarted ||
                  status == IdentityVerificationStatus.rejected) {
                final Object? result = await Navigator.of(
                  context,
                ).pushNamed(AppRoutes.identityVerification);
                if (result is IdentityVerification && context.mounted) {
                  final UserProfile? refreshed = await _profileRepository
                      .refreshProfile();
                  if (context.mounted) {
                    Navigator.of(context).pop(
                      refreshed ??
                          arguments.copyWith(identityVerification: result),
                    );
                  }
                }
                return;
              }
              _showMessage(
                context,
                'Identity corrections require support review and identity re-verification.',
              );
            },
          );
        },

        AppRoutes.identityVerification: (BuildContext context) {
          final Object? arguments = ModalRoute.settingsOf(context)?.arguments;
          final IdentityVerificationEntryPoint entryPoint =
              arguments is IdentityVerificationEntryPoint
              ? arguments
              : IdentityVerificationEntryPoint.account;
          return IdentityVerificationPage(
            controller: IdentityVerificationController(
              repository: _profileRepository,
            ),
            startImmediately:
                entryPoint == IdentityVerificationEntryPoint.signup,
            entryPoint: entryPoint,
            onBack: (IdentityVerification? verification) {
              Navigator.of(context).pop(verification);
            },
          );
        },

        AppRoutes.purchaseIdentityVerification: (BuildContext context) {
          return IdentityVerificationPage(
            controller: IdentityVerificationController(
              repository: _profileRepository,
            ),
            startImmediately: true,
            onBack: (IdentityVerification? verification) {
              Navigator.of(context).pop(verification);
            },
          );
        },

        AppRoutes.securitySettings: (BuildContext context) {
          return SecuritySettingsPage(
            controller: SecuritySettingsController(
              repository: _securityRepository,
              authSessionRepository: _authSessionRepository,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onChangePassword: () async {
              final Object? result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.changePassword);
              if (result == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            onPlaceholderAction: (String action) {
              _showMessage(context, '$action will be connected later.');
            },
            onLogoutSuccess: () {
              _logoutToLogin(context);
            },
          );
        },

        AppRoutes.changePassword: (BuildContext context) {
          return ChangePasswordPage(
            controller: SecuritySettingsController(
              repository: _securityRepository,
              authSessionRepository: _authSessionRepository,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
            onPasswordChanged: () {
              Navigator.of(context).pop(true);
            },
          );
        },

        AppRoutes.notificationSettings: (BuildContext context) {
          return NotificationSettingsPage(
            controller: NotificationPreferencesController(
              repository: _notificationPreferencesRepository,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },

        AppRoutes.payoutMethods: (BuildContext context) {
          return SavedPayoutMethodsPage(
            controller: SavedPayoutMethodsController(
              repository: _payoutRepository,
            ),
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },

        AppRoutes.helpSupport: (BuildContext context) {
          return HelpSupportPage(
            onBack: () {
              Navigator.of(context).pop();
            },
            onAction: (String action) {
              _showMessage(context, '$action will be connected later.');
            },
          );
        },

        AppRoutes.privacyPolicy: (BuildContext context) {
          return LegalPlaceholderPage(
            type: LegalPlaceholderType.privacyPolicy,
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },

        AppRoutes.termsAndConditions: (BuildContext context) {
          return LegalPlaceholderPage(
            type: LegalPlaceholderType.termsAndConditions,
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      },
    );
  }

  Widget _buildDashboardNavigationShell(
    BuildContext context, {
    DashboardNavigationTab initialTab = DashboardNavigationTab.home,
  }) {
    final DashboardNavigationController navigationController =
        DashboardNavigationController(initialTab: initialTab);
    final PoliciesController policiesController = PoliciesController(
      repository: _policiesRepository,
    );
    final DashboardController dashboardController = DashboardController(
      repository: MockDashboardRepository(
        profileRepository: _profileRepository,
      ),
    );
    final ProfileController profileController = ProfileController(
      profileRepository: _profileRepository,
      authSessionRepository: _authSessionRepository,
    );
    return DashboardNavigationShell(
      navigationController: navigationController,
      dashboardController: dashboardController,
      policiesController: policiesController,
      myClaimsController: MyClaimsController(repository: _claimsRepository),
      onFileClaim: () {
        _openFileClaim(context);
      },
      onClaimStatus: () {
        Navigator.of(context).pushNamed(AppRoutes.claimStatus);
      },
      onClaimPressed: (InsuranceClaim claim) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.claimStatus, arguments: claim.id);
      },
      onPayments: () {
        Navigator.of(context).pushNamed(AppRoutes.paymentsHistory);
      },
      onNotifications: () {
        Navigator.of(context).pushNamed(AppRoutes.notificationSettings);
      },
      profilePage: ProfilePage(
        controller: profileController,
        onEditProfile: (UserProfile profile) async {
          final Object? result = await Navigator.of(
            context,
          ).pushNamed(AppRoutes.editProfile, arguments: profile);
          return result is UserProfile ? result : null;
        },
        onIdentityVerification: () async {
          final Object? result = await Navigator.of(
            context,
          ).pushNamed(AppRoutes.identityVerification);
          if (result is! IdentityVerification) {
            return null;
          }
          if (result.status == IdentityVerificationStatus.verified) {
            await dashboardController.refreshDashboard();
          }
          return result;
        },
        onMyPolicies: navigationController.showPolicies,
        onMyClaims: navigationController.showClaims,
        onPayments: () {
          Navigator.of(context).pushNamed(AppRoutes.paymentsHistory);
        },
        onPayoutMethods: () {
          Navigator.of(context).pushNamed(AppRoutes.payoutMethods);
        },
        onSecurity: () {
          Navigator.of(context).pushNamed(AppRoutes.securitySettings);
        },
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notificationSettings);
        },
        onHelpSupport: () {
          Navigator.of(context).pushNamed(AppRoutes.helpSupport);
        },
        onPrivacyPolicy: () {
          Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
        },
        onTermsAndConditions: () {
          Navigator.of(context).pushNamed(AppRoutes.termsAndConditions);
        },
        onLogoutSuccess: () {
          _logoutToLogin(context);
        },
      ),
      onPolicySearch: () async {
        final Object? result = await Navigator.of(
          context,
        ).pushNamed(AppRoutes.insuranceMarketplace);
        if (result == _MarketplaceExit.myPolicies) {
          await policiesController.refresh();
          navigationController.showPolicies();
        } else if (result == _MarketplaceExit.dashboard) {
          navigationController.showHome();
        }
      },
      onPolicyPressed: (InsurancePolicy policy) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.policyDetails, arguments: policy);
      },
      onBuyPolicy: () async {
        final Object? result = await Navigator.of(
          context,
        ).pushNamed(AppRoutes.insuranceMarketplace);
        if (result == _MarketplaceExit.myPolicies) {
          await policiesController.refresh();
          navigationController.showPolicies();
        } else if (result == _MarketplaceExit.dashboard) {
          navigationController.showHome();
        }
      },
    );
  }

  void _openFileClaim(BuildContext context, {InsurancePolicy? policy}) {
    Navigator.of(context).pushNamed(AppRoutes.fileClaim, arguments: policy);
  }

  void _logoutToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }

  void _returnToClaimStatus(BuildContext context, String claimId) {
    final NavigatorState navigator = Navigator.of(context);
    bool foundClaimStatus = false;
    navigator.popUntil((Route<dynamic> route) {
      if (route.settings.name == AppRoutes.claimStatus) {
        foundClaimStatus = true;
        return true;
      }
      return route.isFirst;
    });
    if (!foundClaimStatus) {
      navigator.pushNamed(AppRoutes.claimStatus, arguments: claimId);
    }
  }

  static bool _isPayoutAction(ClaimStatusAction action) {
    return action == ClaimStatusAction.receivePayment ||
        action == ClaimStatusAction.viewVerificationStatus ||
        action == ClaimStatusAction.trackPayment ||
        action == ClaimStatusAction.retryPayment ||
        action == ClaimStatusAction.viewReceipt;
  }

  static String _claimStatusActionMessage(ClaimStatusAction action) {
    return switch (action) {
      ClaimStatusAction.viewSubmittedInformation =>
        'Submitted claim information is shown above.',
      ClaimStatusAction.viewAnalysisProgress =>
        'AI image analysis is still in progress.',
      ClaimStatusAction.contactSupport =>
        'Claim support will be connected next.',
      ClaimStatusAction.uploadEvidence =>
        'Additional-evidence upload will be connected next.',
      ClaimStatusAction.viewDecision => 'The claim decision is shown above.',
      ClaimStatusAction.receivePayment => 'Payment setup is unavailable.',
      ClaimStatusAction.viewVerificationStatus =>
        'Payout method verification is shown in the payment flow.',
      ClaimStatusAction.trackPayment =>
        'The latest payment status is shown in the payment flow.',
      ClaimStatusAction.retryPayment =>
        'Retry the payment from the payment flow.',
      ClaimStatusAction.viewReason =>
        'The decision reason is shown above. Support will be connected next.',
      ClaimStatusAction.viewReceipt =>
        'The payment receipt is shown in the payment flow.',
    };
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

class _SellerDashboardRouteScope extends StatefulWidget {
  const _SellerDashboardRouteScope({
    required this.account,
    required this.repository,
    required this.onNotifications,
    required this.onFeatureUnavailable,
    required this.onReturnToLogin,
  });

  final SellerDashboardAccount? account;
  final SellerDashboardRepository repository;
  final VoidCallback onNotifications;
  final VoidCallback onFeatureUnavailable;
  final VoidCallback onReturnToLogin;

  @override
  State<_SellerDashboardRouteScope> createState() =>
      _SellerDashboardRouteScopeState();
}

class _SellerDashboardRouteScopeState
    extends State<_SellerDashboardRouteScope> {
  late final SellerDashboardController _controller;
  late final SellerDashboardNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _controller = SellerDashboardController(
      repository: widget.repository,
      account: widget.account,
    );
    _navigationController = SellerDashboardNavigationController();
    unawaited(_controller.loadDashboard());
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SellerDashboardNavigationShell(
      navigationController: _navigationController,
      onUnavailableDestination: widget.onFeatureUnavailable,
      home: SellerDashboardPage(
        controller: _controller,
        onNotifications: widget.onNotifications,
        onReturnToLogin: widget.onReturnToLogin,
      ),
    );
  }
}

enum _MarketplaceExit { myPolicies, dashboard }

class _ProductDetailsAction {
  const _ProductDetailsAction.compare(this.productId);

  final String productId;
}

class _InsuranceMarketplaceRouteScope extends StatefulWidget {
  const _InsuranceMarketplaceRouteScope({
    required this.repository,
    required this.onBack,
    required this.onProductPressed,
    required this.onCompare,
  });

  final InsuranceMarketplaceRepository repository;
  final VoidCallback onBack;
  final Future<void> Function(
    InsuranceMarketplaceController controller,
    InsuranceProduct product,
  )
  onProductPressed;
  final ValueChanged<List<InsuranceProduct>> onCompare;

  @override
  State<_InsuranceMarketplaceRouteScope> createState() =>
      _InsuranceMarketplaceRouteScopeState();
}

class _InsuranceMarketplaceRouteScopeState
    extends State<_InsuranceMarketplaceRouteScope> {
  late final InsuranceMarketplaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InsuranceMarketplaceController(repository: widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    return InsuranceMarketplacePage(
      controller: _controller,
      onBack: widget.onBack,
      onProductPressed: (InsuranceProduct product) =>
          widget.onProductPressed(_controller, product),
      onCompare: widget.onCompare,
    );
  }
}

class _InsuranceProductDetailsRouteScope extends StatefulWidget {
  const _InsuranceProductDetailsRouteScope({
    required this.productId,
    required this.repository,
    required this.onBack,
    required this.onBuyNow,
    required this.onCompare,
    required this.onContactSupport,
  });

  final String productId;
  final InsuranceMarketplaceRepository repository;
  final VoidCallback onBack;
  final ValueChanged<InsuranceProduct> onBuyNow;
  final ValueChanged<InsuranceProduct> onCompare;
  final VoidCallback onContactSupport;

  @override
  State<_InsuranceProductDetailsRouteScope> createState() =>
      _InsuranceProductDetailsRouteScopeState();
}

class _InsuranceProductDetailsRouteScopeState
    extends State<_InsuranceProductDetailsRouteScope> {
  late final InsuranceProductController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InsuranceProductController(
      productId: widget.productId,
      repository: widget.repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InsuranceProductDetailsPage(
      controller: _controller,
      onBack: widget.onBack,
      onBuyNow: widget.onBuyNow,
      onCompare: widget.onCompare,
      onContactSupport: widget.onContactSupport,
    );
  }
}

class _PolicyPurchaseRouteScope extends StatefulWidget {
  const _PolicyPurchaseRouteScope({
    required this.productId,
    required this.marketplaceRepository,
    required this.profileRepository,
    required this.purchaseRepository,
    required this.applicationRepository,
    required this.paymentRepository,
    required this.onBack,
    required this.onVerifyIdentity,
    required this.onViewPolicy,
    required this.onViewPaymentReceipt,
    required this.onMyPolicies,
    required this.onDashboard,
    required this.onDownloadDocument,
  });

  final String productId;
  final InsuranceMarketplaceRepository marketplaceRepository;
  final ProfileRepository profileRepository;
  final PolicyPurchaseRepository purchaseRepository;
  final PolicyApplicationRepository applicationRepository;
  final PremiumPaymentRepository paymentRepository;
  final VoidCallback onBack;
  final Future<IdentityVerification?> Function() onVerifyIdentity;
  final ValueChanged<InsurancePolicy> onViewPolicy;
  final ValueChanged<PremiumPayment> onViewPaymentReceipt;
  final VoidCallback onMyPolicies;
  final VoidCallback onDashboard;
  final VoidCallback onDownloadDocument;

  @override
  State<_PolicyPurchaseRouteScope> createState() =>
      _PolicyPurchaseRouteScopeState();
}

class _PolicyPurchaseRouteScopeState extends State<_PolicyPurchaseRouteScope> {
  late final PolicyPurchaseController _purchaseController;
  late final PolicyQuoteController _quoteController;
  late final PolicyApplicationController _applicationController;
  late final PremiumPaymentController _paymentController;

  @override
  void initState() {
    super.initState();
    _purchaseController = PolicyPurchaseController(
      marketplaceRepository: widget.marketplaceRepository,
      profileRepository: widget.profileRepository,
      purchaseRepository: widget.purchaseRepository,
      productId: widget.productId,
    );
    _quoteController = PolicyQuoteController(
      repository: widget.purchaseRepository,
    );
    _applicationController = PolicyApplicationController(
      repository: widget.applicationRepository,
    );
    _paymentController = PremiumPaymentController(
      repository: widget.paymentRepository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PolicyPurchasePage(
      purchaseController: _purchaseController,
      quoteController: _quoteController,
      applicationController: _applicationController,
      paymentController: _paymentController,
      onBack: widget.onBack,
      onVerifyIdentity: widget.onVerifyIdentity,
      onViewPolicy: widget.onViewPolicy,
      onViewPaymentReceipt: widget.onViewPaymentReceipt,
      onMyPolicies: widget.onMyPolicies,
      onDashboard: widget.onDashboard,
      onDownloadDocument: widget.onDownloadDocument,
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

class _ClaimStatusRouteScope extends StatefulWidget {
  const _ClaimStatusRouteScope({
    required this.onBack,
    required this.onFileClaim,
    required this.onContextualAction,
    required this.invalidArgument,
    required this.claimsRepository,
    required this.payoutRepository,
    this.claimId,
    this.initialClaim,
  });

  final String? claimId;
  final InsuranceClaim? initialClaim;
  final bool invalidArgument;
  final ClaimStatusRepository claimsRepository;
  final ClaimPayoutRepository payoutRepository;
  final VoidCallback onBack;
  final VoidCallback onFileClaim;
  final Future<void> Function(ClaimStatusAction, InsuranceClaim?)
  onContextualAction;

  @override
  State<_ClaimStatusRouteScope> createState() => _ClaimStatusRouteScopeState();
}

class _ClaimStatusRouteScopeState extends State<_ClaimStatusRouteScope> {
  late final ClaimStatusController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClaimStatusController(
      repository: widget.claimsRepository,
      payoutRepository: widget.payoutRepository,
      initialClaim: widget.initialClaim,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClaimStatusPage(
      controller: _controller,
      claimId: widget.claimId,
      invalidArgument: widget.invalidArgument,
      onBack: widget.onBack,
      onFileClaim: widget.onFileClaim,
      onContextualAction: (ClaimStatusAction action) async {
        await widget.onContextualAction(action, _controller.claim);
        await _controller.refresh();
      },
    );
  }
}
