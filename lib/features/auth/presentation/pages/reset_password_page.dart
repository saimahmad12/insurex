import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/reset_password_controller.dart';
import '../validators/reset_password_validator.dart';
import '../widgets/forgot_password_logo.dart';
import '../widgets/password_recovery_progress.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    required this.identity,
    required this.controller,
    required this.onBack,
    required this.onResetSuccess,
    required this.onBackToLogin,
    super.key,
  });

  final String identity;

  final ResetPasswordController controller;

  final VoidCallback onBack;
  final VoidCallback onResetSuccess;
  final VoidCallback onBackToLogin;

  @override
  State<ResetPasswordPage> createState() {
    return _ResetPasswordPageState();
  }
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String _password = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    widget.controller.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final bool success =
    await widget.controller.resetPassword(
      identity: widget.identity,
      newPassword:
      _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    widget.onResetSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (
                BuildContext context,
                BoxConstraints constraints,
                ) {
              final double logoSize =
              (constraints.maxHeight * 0.18)
                  .clamp(
                125.0,
                155.0,
              );

              return SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  24 +
                      MediaQuery.viewInsetsOf(
                        context,
                      ).bottom *
                          0.10,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                    constraints.maxHeight -
                        36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 430,
                      ),
                      child: AnimatedBuilder(
                        animation:
                        widget.controller,
                        builder: (
                            BuildContext context,
                            Widget? child,
                            ) {
                          return Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                            children: <Widget>[
                              _BackButton(
                                onPressed:
                                widget.onBack,
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              ForgotPasswordLogo(
                                size: logoSize,
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              const PasswordRecoveryProgress(
                                currentStep:
                                PasswordRecoveryStep.password,
                              ),

                              const SizedBox(
                                height: 24,
                              ),

                              const Text(
                                'Create New Password',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color:
                                  Colors.black87,
                                  fontSize: 29,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing:
                                  -0.4,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Text(
                                'Your new password must be '
                                    'different from your previous '
                                    'password.',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.76,
                                  ),
                                  fontSize: 13.5,
                                  height: 1.45,
                                ),
                              ),

                              const SizedBox(
                                height: 25,
                              ),

                              GlassContainer(
                                width:
                                double.infinity,
                                padding:
                                const EdgeInsets
                                    .fromLTRB(
                                  18,
                                  23,
                                  18,
                                  21,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children:
                                    <Widget>[
                                      _PasswordField(
                                        controller:
                                        _passwordController,
                                        label:
                                        'New Password',
                                        hint:
                                        'Enter new password',
                                        obscureText:
                                        !_showPassword,
                                        onVisibilityPressed:
                                            () {
                                          setState(() {
                                            _showPassword =
                                            !_showPassword;
                                          });
                                        },
                                        validator:
                                        ResetPasswordValidator
                                            .validatePassword,
                                        onChanged: (
                                            String value,
                                            ) {
                                          setState(() {
                                            _password =
                                                value;
                                          });

                                          widget.controller
                                              .clearError();
                                        },
                                      ),

                                      const SizedBox(
                                        height: 16,
                                      ),

                                      _PasswordField(
                                        controller:
                                        _confirmPasswordController,
                                        label:
                                        'Confirm New Password',
                                        hint:
                                        'Confirm new password',
                                        obscureText:
                                        !_showConfirmPassword,
                                        onVisibilityPressed:
                                            () {
                                          setState(() {
                                            _showConfirmPassword =
                                            !_showConfirmPassword;
                                          });
                                        },
                                        validator: (
                                            String? value,
                                            ) {
                                          return ResetPasswordValidator
                                              .validateConfirmPassword(
                                            value:
                                            value,
                                            password:
                                            _passwordController
                                                .text,
                                          );
                                        },
                                        onChanged: (
                                            String value,
                                            ) {
                                          widget.controller
                                              .clearError();
                                        },
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      _PasswordRequirements(
                                        password:
                                        _password,
                                      ),

                                      if (widget
                                          .controller
                                          .errorMessage !=
                                          null) ...<Widget>[
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        _ErrorMessage(
                                          message: widget
                                              .controller
                                              .errorMessage!,
                                        ),
                                      ],

                                      const SizedBox(
                                        height: 22,
                                      ),

                                      GlassActionButton(
                                        label:
                                        'Reset Password',
                                        icon: Icons
                                            .arrow_forward_rounded,
                                        isLoading: widget
                                            .controller
                                            .isLoading,
                                        onPressed: widget
                                            .controller
                                            .isLoading
                                            ? null
                                            : _submit,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              TextButton(
                                onPressed: widget
                                    .onBackToLogin,
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color:
                                    AppColors.blue,
                                    fontWeight:
                                    FontWeight
                                        .w800,
                                  ),
                                ),
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onVisibilityPressed,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;

  final String label;
  final String hint;

  final bool obscureText;

  final VoidCallback onVisibilityPressed;

  final FormFieldValidator<String> validator;

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          obscuringCharacter: '●',
          keyboardType:
          TextInputType.visiblePassword,
          textInputAction:
          TextInputAction.next,
          validator: validator,
          onChanged: onChanged,
          cursorColor: AppColors.blue,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.55,
              ),
            ),

            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color:
              AppColors.textSecondary,
            ),

            suffixIcon: IconButton(
              onPressed:
              onVisibilityPressed,
              icon: Icon(
                obscureText
                    ? Icons
                    .visibility_off_outlined
                    : Icons
                    .visibility_outlined,
                color:
                AppColors.textSecondary,
              ),
            ),

            filled: true,

            fillColor:
            AppColors.white.withValues(
              alpha: 0.07,
            ),

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 17,
            ),

            enabledBorder:
            _fieldBorder(
              AppColors.white.withValues(
                alpha: 0.22,
              ),
            ),

            focusedBorder:
            _fieldBorder(
              AppColors.blue,
              width: 1.4,
            ),

            errorBorder:
            _fieldBorder(
              const Color(0xFFFF8A9B),
            ),

            focusedErrorBorder:
            _fieldBorder(
              const Color(0xFFFF8A9B),
              width: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder(
      Color color, {
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}

class _PasswordRequirements
    extends StatelessWidget {
  const _PasswordRequirements({
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
        AppColors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          AppColors.white.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Password Requirements',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 11),

          _RequirementItem(
            text:
            'At least 8 characters',
            completed:
            ResetPasswordValidator
                .hasMinimumLength(
              password,
            ),
          ),

          const SizedBox(height: 8),

          _RequirementItem(
            text:
            'One uppercase letter (A-Z)',
            completed:
            ResetPasswordValidator
                .hasUppercase(
              password,
            ),
          ),

          const SizedBox(height: 8),

          _RequirementItem(
            text:
            'One lowercase letter (a-z)',
            completed:
            ResetPasswordValidator
                .hasLowercase(
              password,
            ),
          ),

          const SizedBox(height: 8),

          _RequirementItem(
            text:
            'One number (0-9)',
            completed:
            ResetPasswordValidator
                .hasNumber(
              password,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem
    extends StatelessWidget {
  const _RequirementItem({
    required this.text,
    required this.completed,
  });

  final String text;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final Color color =
    completed
        ? const Color(0xFF65E39C)
        : AppColors.textSecondary;

    return Row(
      children: <Widget>[
        Icon(
          completed
              ? Icons
              .check_circle_rounded
              : Icons
              .radio_button_unchecked_rounded,
          color: color,
          size: 18,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor:
          AppColors.white.withValues(
            alpha: 0.09,
          ),
          side: BorderSide(
            color:
            AppColors.white.withValues(
              alpha: 0.20,
            ),
          ),
        ),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ErrorMessage
    extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
        const Color(0xFFFF6680)
            .withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          const Color(0xFFFF8A9B)
              .withValues(
            alpha: 0.50,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons
                .error_outline_rounded,
            color:
            Color(0xFFFFB3BE),
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              message,
              style:
              const TextStyle(
                color:
                Color(0xFFB3261E),
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
