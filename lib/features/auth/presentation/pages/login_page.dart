import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/login_controller.dart';
import '../../domain/entities/account_role.dart';
import '../validators/login_form_validator.dart';
import '../widgets/account_role_selector.dart';
import '../widgets/auth_shield_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/google_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.controller,
    required this.onBack,
    required this.onLoginSuccess,
    super.key,
    this.onForgotPassword,
    this.onSignUp,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.onBiometricLogin,
    this.onRoleSelected,
  });

  final LoginController controller;
  final VoidCallback onBack;
  final VoidCallback onLoginSuccess;

  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;
  final VoidCallback? onBiometricLogin;
  final ValueChanged<AccountRole>? onRoleSelected;

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _identityController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    widget.controller.dispose();

    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    final bool authenticated = await widget.controller.login(
      identity: _identityController.text,
      password: _passwordController.text,
    );

    if (!mounted || !authenticated) {
      return;
    }

    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  24 + MediaQuery.viewInsetsOf(context).bottom * 0.15,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
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

                              const SizedBox(height: 4),

                              const AuthShieldLogo(),

                              const SizedBox(height: 18),

                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                'Login to continue to your secure account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.78,
                                  ),
                                  fontSize: 13.5,
                                ),
                              ),

                              const SizedBox(height: 25),

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
                                        AccountRoleSelector(
                                          selectedRole: AccountRole.customer,
                                          enabled: !widget.controller.isLoading,
                                          onRoleSelected:
                                              widget.onRoleSelected ?? (_) {},
                                        ),

                                        const SizedBox(height: 17),

                                        AuthTextField(
                                          key: const Key(
                                            'login_identity_field',
                                          ),
                                          controller: _identityController,
                                          label: 'Mobile number or email',
                                          hintText: '+92 300 1234567',
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const <String>[
                                            AutofillHints.username,
                                            AutofillHints.email,
                                            AutofillHints.telephoneNumber,
                                          ],
                                          validator: LoginFormValidator
                                              .validateIdentity,
                                          onChanged: (String value) {
                                            widget.controller.clearError();
                                          },
                                        ),

                                        const SizedBox(height: 15),

                                        AuthTextField(
                                          key: const Key(
                                            'login_password_field',
                                          ),
                                          controller: _passwordController,
                                          label: 'Password',
                                          hintText: 'Enter your password',
                                          prefixIcon:
                                              Icons.lock_outline_rounded,
                                          textInputAction: TextInputAction.done,
                                          obscureText: true,
                                          autofillHints: const <String>[
                                            AutofillHints.password,
                                          ],
                                          validator: LoginFormValidator
                                              .validatePassword,
                                          onChanged: (String value) {
                                            widget.controller.clearError();
                                          },
                                          onSubmitted: (String value) {
                                            _submitLogin();
                                          },
                                        ),

                                        const SizedBox(height: 8),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: widget.onForgotPassword,
                                            child: const Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: AppColors.blue,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),

                                        if (widget.controller.errorMessage !=
                                            null) ...<Widget>[
                                          _LoginErrorMessage(
                                            message:
                                                widget.controller.errorMessage!,
                                          ),
                                          const SizedBox(height: 13),
                                        ],

                                        GlassActionButton(
                                          key: const Key('login_button'),
                                          label: 'Login',
                                          icon: Icons.login_rounded,
                                          isLoading:
                                              widget.controller.isLoading,
                                          onPressed: widget.controller.isLoading
                                              ? null
                                              : _submitLogin,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 21),

                              const _SocialDivider(),

                              const SizedBox(height: 17),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SocialLoginButton(
                                    tooltip: 'Continue with Google',
                                    onPressed: widget.onGoogleLogin,
                                    child: const GoogleLogo(size: 27),
                                  ),

                                  const SizedBox(width: 13),

                                  SocialLoginButton(
                                    tooltip: 'Continue with Apple',
                                    onPressed: widget.onAppleLogin,
                                    child: const Icon(
                                      Icons.apple_rounded,
                                      color: AppColors.black,
                                      size: 27,
                                    ),
                                  ),

                                  const SizedBox(width: 13),

                                  SocialLoginButton(
                                    tooltip: 'Use biometric login',
                                    onPressed: widget.onBiometricLogin,
                                    child: const Icon(
                                      Icons.fingerprint_rounded,
                                      color: AppColors.black,
                                      size: 27,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: widget.onSignUp,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: AppColors.blue,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

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
              style: const TextStyle(color: Color(0xFFB3261E), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

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
            'or continue with',
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
