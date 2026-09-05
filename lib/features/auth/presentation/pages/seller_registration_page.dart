import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/seller_registration_controller.dart';
import '../../application/validators/seller_auth_validator.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/seller_registration.dart';
import '../widgets/account_role_selector.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/seller_auth_form_fields.dart';
import '../widgets/signup_logo.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({
    required this.controller,
    required this.onBack,
    required this.onRoleSelected,
    required this.onSubmitted,
    required this.onLoginPressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
  });

  final SellerRegistrationController controller;
  final VoidCallback onBack;
  final ValueChanged<AccountRole> onRoleSelected;
  final ValueChanged<SellerRegistrationResult> onSubmitted;
  final VoidCallback onLoginPressed;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  State<SellerRegistrationPage> createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _representativeNameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _registrationNumberController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _representativeNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final SellerRegistrationResult? result = await widget.controller.submit(
      registeredCompanyName: _companyNameController.text,
      businessEmail: _emailController.text,
      businessPhoneNumber: _phoneController.text,
      companyRegistrationNumber: _registrationNumberController.text,
      insuranceLicenseNumber: _licenseNumberController.text,
      officeAddress: _addressController.text,
      authorizedRepresentativeName: _representativeNameController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (mounted && result != null) {
      widget.onSubmitted(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double logoSize = (constraints.maxHeight * 0.14).clamp(
                105.0,
                145.0,
              );
              return SingleChildScrollView(
                key: const Key('seller_registration_scroll'),
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  28 + MediaQuery.viewInsetsOf(context).bottom * 0.12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (BuildContext context, Widget? child) {
                        final bool enabled = !widget.controller.isSubmitting;
                        return Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                key: const Key('seller_registration_back'),
                                tooltip: 'Back',
                                onPressed: widget.onBack,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.white.withValues(
                                    alpha: 0.09,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.white.withValues(
                                      alpha: 0.20,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            SignupLogo(width: logoSize, height: logoSize),
                            const SizedBox(height: 6),
                            const Text(
                              'Register Insurance Company',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Create a company account for administrator review',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.78,
                                ),
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 22),
                            GlassContainer(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                22,
                                18,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AccountRoleSelector(
                                    selectedRole: AccountRole.seller,
                                    enabled: enabled,
                                    onRoleSelected: widget.onRoleSelected,
                                  ),
                                  const SizedBox(height: 20),
                                  const _SectionTitle('Company details'),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key('seller_company_name_field'),
                                    controller: _companyNameController,
                                    label: 'Registered company name',
                                    hintText: 'Enter the legal company name',
                                    prefixIcon: Icons.business_rounded,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .registeredCompanyName,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .registeredCompanyName,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_business_email_field',
                                    ),
                                    controller: _emailController,
                                    label: 'Business email',
                                    hintText: 'company@example.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField.businessEmail,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField.businessEmail,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_business_phone_field',
                                    ),
                                    controller: _phoneController,
                                    label: 'Business phone number',
                                    hintText: '+92 300 1234567',
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .businessPhoneNumber,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .businessPhoneNumber,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_company_registration_field',
                                    ),
                                    controller: _registrationNumberController,
                                    label: 'Company registration number',
                                    hintText: 'e.g. SECP-123456',
                                    prefixIcon: Icons.badge_outlined,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .companyRegistrationNumber,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .companyRegistrationNumber,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key('seller_license_field'),
                                    controller: _licenseNumberController,
                                    label: 'Insurance license number',
                                    hintText: 'Enter regulator-issued license',
                                    prefixIcon: Icons.verified_outlined,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .insuranceLicenseNumber,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .insuranceLicenseNumber,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_office_address_field',
                                    ),
                                    controller: _addressController,
                                    label: 'Registered office address',
                                    hintText:
                                        'Enter the complete office address',
                                    prefixIcon: Icons.location_on_outlined,
                                    textInputAction: TextInputAction.next,
                                    maxLines: 2,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField.officeAddress,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField.officeAddress,
                                        ),
                                  ),
                                  const SizedBox(height: 22),
                                  const _SectionTitle(
                                    'Authorized representative',
                                  ),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_representative_name_field',
                                    ),
                                    controller: _representativeNameController,
                                    label: 'Authorized representative name',
                                    hintText: 'Enter the representative name',
                                    prefixIcon: Icons.person_outline_rounded,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .authorizedRepresentativeName,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .authorizedRepresentativeName,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  AuthDropdownField<RepresentativeDesignation>(
                                    key: const Key(
                                      'seller_representative_designation_field',
                                    ),
                                    label: 'Representative designation',
                                    hintText: 'Select designation',
                                    prefixIcon: Icons.work_outline_rounded,
                                    value: widget.controller.designation,
                                    items: RepresentativeDesignation.values,
                                    itemLabel:
                                        (RepresentativeDesignation value) =>
                                            value.label,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .authorizedRepresentativeDesignation,
                                    ),
                                    onChanged: enabled
                                        ? widget.controller.selectDesignation
                                        : null,
                                  ),
                                  const SizedBox(height: 20),
                                  InsuranceCategorySelector(
                                    selectedCategories:
                                        widget.controller.selectedCategories,
                                    enabled: enabled,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField
                                          .supportedCategories,
                                    ),
                                    onToggle: widget.controller.toggleCategory,
                                  ),
                                  const SizedBox(height: 22),
                                  const _SectionTitle('Account security'),
                                  const SizedBox(height: 13),
                                  AuthTextField(
                                    key: const Key('seller_password_field'),
                                    controller: _passwordController,
                                    label: 'Password',
                                    hintText: 'Create a strong password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField.password,
                                    ),
                                    onChanged: (_) {
                                      setState(() {});
                                      widget.controller.clearFieldError(
                                        SellerRegistrationField.password,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  PasswordStrengthIndicator(
                                    password: _passwordController.text,
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key(
                                      'seller_confirm_password_field',
                                    ),
                                    controller: _confirmPasswordController,
                                    label: 'Confirm password',
                                    hintText: 'Enter password again',
                                    prefixIcon: Icons.lock_reset_rounded,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    errorText: widget.controller.errorFor(
                                      SellerRegistrationField.confirmPassword,
                                    ),
                                    onChanged: (_) =>
                                        widget.controller.clearFieldError(
                                          SellerRegistrationField
                                              .confirmPassword,
                                        ),
                                    onSubmitted: (_) => _submit(),
                                  ),
                                  const SizedBox(height: 13),
                                  SellerTermsDeclarations(
                                    acceptedTerms:
                                        widget.controller.acceptedTerms,
                                    confirmedDeclarations:
                                        widget.controller.confirmedDeclarations,
                                    enabled: enabled,
                                    termsError: widget.controller.errorFor(
                                      SellerRegistrationField.terms,
                                    ),
                                    declarationsError: widget.controller
                                        .errorFor(
                                          SellerRegistrationField.declarations,
                                        ),
                                    onTermsChanged:
                                        widget.controller.setTermsAccepted,
                                    onDeclarationsChanged: widget
                                        .controller
                                        .setDeclarationsConfirmed,
                                    onTermsPressed: widget.onTermsPressed,
                                    onPrivacyPressed: widget.onPrivacyPressed,
                                  ),
                                  if (widget.controller.errorMessage !=
                                      null) ...<Widget>[
                                    const SizedBox(height: 12),
                                    SellerAuthMessage(
                                      message: widget.controller.errorMessage!,
                                    ),
                                  ],
                                  const SizedBox(height: 17),
                                  GlassActionButton(
                                    key: const Key(
                                      'seller_registration_submit_button',
                                    ),
                                    label: 'Submit for Approval',
                                    icon: Icons.send_rounded,
                                    isLoading: widget.controller.isSubmitting,
                                    onPressed: enabled ? _submit : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Already registered?',
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.78,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  key: const Key('seller_registration_login'),
                                  onPressed: widget.onLoginPressed,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: AppColors.pink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
