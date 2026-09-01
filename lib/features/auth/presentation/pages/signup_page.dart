import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/signup_controller.dart';
import '../validators/signup_form_validator.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_logo.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/signup_logo.dart';
import '../widgets/social_login_button.dart';
import '../widgets/terms_agreement.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({
    required this.controller,
    required this.onBack,
    required this.onContinueToIdentityVerification,
    required this.onLoginPressed,
    super.key,
    this.onGoogleSignup,
    this.onAppleSignup,
    this.onTermsPressed,
    this.onPrivacyPressed,
  });

  final SignupController controller;

  final VoidCallback onBack;
  final Future<void> Function() onContinueToIdentityVerification;
  final VoidCallback onLoginPressed;

  final VoidCallback? onGoogleSignup;
  final VoidCallback? onAppleSignup;
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _mobileController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _acceptedTerms = false;
  bool _showTermsError = false;
  String _passwordValue = '';
  bool _isOpeningIdentityVerification = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    widget.controller.dispose();

    super.dispose();
  }

  Future<void> _submitSignup() async {
    if (_isOpeningIdentityVerification || widget.controller.isLoading) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _showTermsError = !_acceptedTerms;
    });

    if (!isFormValid || !_acceptedTerms) {
      return;
    }

    _isOpeningIdentityVerification = true;
    try {
      final bool prepared = await widget.controller.prepareAccountDetails(
        fullName: _fullNameController.text,
        email: _emailController.text,
        mobileNumber: _mobileController.text,
        password: _passwordController.text,
      );
      if (!mounted || !prepared) {
        return;
      }
      await widget.onContinueToIdentityVerification();
    } finally {
      _isOpeningIdentityVerification = false;
    }
  }

  void _clearControllerError() {
    widget.controller.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double logoSize = (constraints.maxHeight * 0.19).clamp(
                135.0,
                175.0,
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  24 + MediaQuery.viewInsetsOf(context).bottom * 0.12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: AnimatedBuilder(
                        animation: widget.controller,
                        builder: (BuildContext context, Widget? child) {
                          return Column(
                            children: <Widget>[
                              _BackButton(onPressed: widget.onBack),

                              const SizedBox(height: 2),

                              SignupLogo(width: logoSize, height: logoSize),

                              const SizedBox(height: 8),

                              const Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 29,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                'Join InsureX and manage your '
                                'insurance securely',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.78,
                                  ),
                                  fontSize: 13.5,
                                ),
                              ),

                              const SizedBox(height: 23),

                              GlassContainer(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  22,
                                  18,
                                  20,
                                ),
                                child: AutofillGroup(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        AuthTextField(
                                          key: const Key(
                                            'signup_full_name_field',
                                          ),
                                          controller: _fullNameController,
                                          label:
                                              'Full name as shown on your CNIC',
                                          hintText:
                                              'Enter your name as shown on your CNIC',
                                          helperText:
                                              'This name will be confirmed during identity verification.',
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          keyboardType: TextInputType.name,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const <String>[
                                            AutofillHints.name,
                                          ],
                                          validator: SignupFormValidator
                                              .validateFullName,
                                          onChanged: (String value) {
                                            _clearControllerError();
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        AuthTextField(
                                          key: const Key('signup_email_field'),
                                          controller: _emailController,
                                          label: 'Email address',
                                          hintText: 'example@email.com',
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const <String>[
                                            AutofillHints.email,
                                          ],
                                          validator:
                                              SignupFormValidator.validateEmail,
                                          onChanged: (String value) {
                                            _clearControllerError();
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        AuthTextField(
                                          key: const Key('signup_mobile_field'),
                                          controller: _mobileController,
                                          label: 'Mobile number',
                                          hintText: '+92 300 1234567',
                                          prefixIcon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const <String>[
                                            AutofillHints.telephoneNumber,
                                          ],
                                          validator: SignupFormValidator
                                              .validateMobileNumber,
                                          onChanged: (String value) {
                                            _clearControllerError();
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        AuthTextField(
                                          key: const Key(
                                            'signup_password_field',
                                          ),
                                          controller: _passwordController,
                                          label: 'Password',
                                          hintText: 'Create a strong password',
                                          prefixIcon:
                                              Icons.lock_outline_rounded,
                                          obscureText: true,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const <String>[
                                            AutofillHints.newPassword,
                                          ],
                                          validator: SignupFormValidator
                                              .validatePassword,
                                          onChanged: (String value) {
                                            setState(() {
                                              _passwordValue = value;
                                            });

                                            _clearControllerError();
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        PasswordStrengthIndicator(
                                          password: _passwordValue,
                                        ),

                                        const SizedBox(height: 14),

                                        AuthTextField(
                                          key: const Key(
                                            'signup_confirm_password_field',
                                          ),
                                          controller:
                                              _confirmPasswordController,
                                          label: 'Confirm password',
                                          hintText: 'Enter password again',
                                          prefixIcon: Icons.lock_reset_rounded,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const <String>[
                                            AutofillHints.newPassword,
                                          ],
                                          validator: (String? value) {
                                            return SignupFormValidator.validateConfirmPassword(
                                              value,
                                              _passwordController.text,
                                            );
                                          },
                                          onChanged: (String value) {
                                            _clearControllerError();
                                          },
                                          onSubmitted: (String value) {
                                            _submitSignup();
                                          },
                                        ),

                                        const SizedBox(height: 12),

                                        TermsAgreement(
                                          value: _acceptedTerms,
                                          showError: _showTermsError,
                                          onTermsPressed: widget.onTermsPressed,
                                          onPrivacyPressed:
                                              widget.onPrivacyPressed,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _acceptedTerms = value;
                                              _showTermsError = false;
                                            });
                                          },
                                        ),

                                        if (widget.controller.errorMessage !=
                                            null) ...<Widget>[
                                          const SizedBox(height: 12),
                                          _SignupErrorMessage(
                                            message:
                                                widget.controller.errorMessage!,
                                          ),
                                        ],

                                        const SizedBox(height: 16),

                                        GlassActionButton(
                                          key: const Key(
                                            'signup_continue_button',
                                          ),
                                          label: 'Continue',
                                          icon: Icons.person_add_alt_1_rounded,
                                          isLoading:
                                              widget.controller.isLoading,
                                          onPressed: widget.controller.isLoading
                                              ? null
                                              : _submitSignup,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 21),

                              const _SignupDivider(),

                              const SizedBox(height: 17),

                              _SocialSignupSection(
                                onGoogleSignup: widget.onGoogleSignup,
                                onAppleSignup: widget.onAppleSignup,
                              ),

                              const SizedBox(height: 19),

                              _LoginLink(onLoginPressed: widget.onLoginPressed),
                            ],
                          );
                        },
                      ),
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.white.withValues(alpha: 0.09),
          side: BorderSide(color: AppColors.white.withValues(alpha: 0.20)),
        ),
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
      ),
    );
  }
}

class _SocialSignupSection extends StatelessWidget {
  const _SocialSignupSection({
    required this.onGoogleSignup,
    required this.onAppleSignup,
  });

  final VoidCallback? onGoogleSignup;
  final VoidCallback? onAppleSignup;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SocialLoginButton(
          tooltip: 'Sign up with Google',
          onPressed: onGoogleSignup,
          child: const GoogleLogo(size: 27),
        ),
        const SizedBox(width: 13),
        SocialLoginButton(
          tooltip: 'Sign up with Apple',
          onPressed: onAppleSignup,
          child: const Icon(
            Icons.apple_rounded,
            color: AppColors.white,
            size: 27,
          ),
        ),
      ],
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Already have an account?',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.76),
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: onLoginPressed,
          child: const Text(
            'Login',
            style: TextStyle(
              color: AppColors.pink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignupErrorMessage extends StatelessWidget {
  const _SignupErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6680).withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFF8A9B).withValues(alpha: 0.50),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 19,
            color: Color(0xFFFFB3BE),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFD6DC), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupDivider extends StatelessWidget {
  const _SignupDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(color: AppColors.white.withValues(alpha: 0.20)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            'or sign up with',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.64),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.white.withValues(alpha: 0.20)),
        ),
      ],
    );
  }
}
