abstract final class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';

  static const String login = '/login';

  static const String signup = '/signup';

  static const String sellerLogin = '/login/seller';

  static const String sellerSignup = '/signup/seller';

  static const String sellerRegistrationSubmitted = '/signup/seller/submitted';

  static const String sellerAccountStatus = '/login/seller/status';

  static const String sellerDashboard = '/seller/dashboard';

  static const String sellerHome = sellerDashboard;

  static const String forgotPassword = '/forgot-password';

  static const String otpVerification = '/otp-verification';

  static const String resetPassword = '/reset-password';

  static const String dashboard = '/dashboard';

  static const String myPolicies = '/my-policies';

  static const String myClaims = '/my-claims';

  static const String policyDetails = '/policy-details';

  static const String insuranceMarketplace = '/insurance-marketplace';

  static const String insuranceProductDetails =
      '/insurance-marketplace/product';

  static const String insuranceComparison = '/insurance-marketplace/comparison';

  static const String policyPurchase = '/policy-purchase';

  static const String premiumPaymentReceipt =
      '/policy-purchase/payment-receipt';

  static const String fileClaim = '/file-claim';

  static const String claimSubmitted = '/claim-submitted';

  static const String claimStatus = '/claim-status';

  static const String claimPayout = '/claim-payout';

  static const String paymentsHistory = '/payments';

  static const String editProfile = '/profile/edit';

  static const String identityVerification = '/profile/identity-verification';

  static const String purchaseIdentityVerification =
      '/policy-purchase/identity-verification';

  static const String securitySettings = '/profile/security';

  static const String changePassword = '/profile/security/change-password';

  static const String notificationSettings = '/profile/notifications';

  static const String payoutMethods = '/profile/payout-methods';

  static const String helpSupport = '/profile/help-support';

  static const String privacyPolicy = '/profile/privacy-policy';

  static const String termsAndConditions = '/profile/terms-and-conditions';
}
