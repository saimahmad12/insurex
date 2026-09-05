import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/seller_login_controller.dart';
import '../../application/validators/seller_auth_validator.dart';
import '../../domain/entities/account_role.dart';
import '../../domain/entities/seller_authentication.dart';
import '../widgets/account_role_selector.dart';
import '../widgets/auth_shield_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/seller_auth_form_fields.dart';

class SellerLoginPage extends StatefulWidget {
  const SellerLoginPage({
    required this.controller,
    required this.onBack,
    required this.onRoleSelected,
    required this.onLoginResolved,
    required this.onForgotPassword,
    required this.onSignupPressed,
    super.key,
  });

  final SellerLoginController controller;
  final VoidCallback onBack;
  final ValueChanged<AccountRole> onRoleSelected;
  final ValueChanged<SellerAuthenticationResult> onLoginResolved;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignupPressed;

  @override
  State<SellerLoginPage> createState() => _SellerLoginPageState();
}

class _SellerLoginPageState extends State<SellerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final SellerAuthenticationResult? result = await widget.controller.login(
      businessEmail: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted && result != null) {
      widget.onLoginResolved(result);
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
              return SingleChildScrollView(
                key: const Key('seller_login_scroll'),
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
                          final bool enabled = !widget.controller.isLoading;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  key: const Key('seller_login_back'),
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
                                'Company Portal',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Login with your approved insurance company account',
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
                                child: Column(
                                  children: <Widget>[
                                    AccountRoleSelector(
                                      selectedRole: AccountRole.seller,
                                      enabled: enabled,
                                      onRoleSelected: widget.onRoleSelected,
                                    ),
                                    const SizedBox(height: 17),
                                    AuthTextField(
                                      key: const Key(
                                        'seller_login_email_field',
                                      ),
                                      controller: _emailController,
                                      label: 'Business email',
                                      hintText: 'company@example.com',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                        AutofillHints.username,
                                      ],
                                      errorText: widget.controller.errorFor(
                                        SellerLoginField.businessEmail,
                                      ),
                                      onChanged: (_) =>
                                          widget.controller.clearFieldError(
                                            SellerLoginField.businessEmail,
                                          ),
                                    ),
                                    const SizedBox(height: 15),
                                    AuthTextField(
                                      key: const Key(
                                        'seller_login_password_field',
                                      ),
                                      controller: _passwordController,
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.password,
                                      ],
                                      errorText: widget.controller.errorFor(
                                        SellerLoginField.password,
                                      ),
                                      onChanged: (_) =>
                                          widget.controller.clearFieldError(
                                            SellerLoginField.password,
                                          ),
                                      onSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        key: const Key(
                                          'seller_forgot_password_button',
                                        ),
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
                                      SellerAuthMessage(
                                        message:
                                            widget.controller.errorMessage!,
                                      ),
                                      const SizedBox(height: 13),
                                    ],
                                    GlassActionButton(
                                      key: const Key('seller_login_button'),
                                      label: 'Company Login',
                                      icon: Icons.login_rounded,
                                      isLoading: widget.controller.isLoading,
                                      onPressed: enabled ? _submit : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Don't have a company account?",
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.76,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    key: const Key('seller_login_signup'),
                                    onPressed: widget.onSignupPressed,
                                    child: const Text(
                                      'Register',
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
