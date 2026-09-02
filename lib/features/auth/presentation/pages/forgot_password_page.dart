import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/forgot_password_controller.dart';
import '../validators/forgot_password_validator.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/forgot_password_logo.dart';
import '../widgets/password_recovery_progress.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    required this.controller,
    required this.onBack,
    required this.onBackToLogin,
    required this.onContinueToVerification,
    super.key,
  });

  final ForgotPasswordController controller;

  final VoidCallback onBack;
  final VoidCallback onBackToLogin;

  /// Sends the entered email/mobile number to the OTP screen.
  final ValueChanged<String> onContinueToVerification;

  @override
  State<ForgotPasswordPage> createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _identityController =
  TextEditingController();

  @override
  void dispose() {
    _identityController.dispose();
    widget.controller.dispose();

    super.dispose();
  }

  Future<void> _submitRequest() async {
    // Hide keyboard.
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate email/mobile.
    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final String identity =
    _identityController.text.trim();

    // Mock/API call through controller.
    final bool sent =
    await widget.controller.requestPasswordReset(
      identity: identity,
    );

    // User might leave screen while request is running.
    if (!mounted || !sent) {
      return;
    }

    // Navigate to OTP screen and send the email/mobile with it.
    widget.onContinueToVerification(
      identity,
    );
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
              (constraints.maxHeight * 0.21).clamp(
                140.0,
                175.0,
              );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  24 +
                      MediaQuery.viewInsetsOf(context)
                          .bottom *
                          0.15,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 430,
                      ),
                      child: AnimatedBuilder(
                        animation: widget.controller,
                        builder: (
                            BuildContext context,
                            Widget? child,
                            ) {
                          return _RequestContent(
                            formKey: _formKey,
                            identityController:
                            _identityController,
                            controller:
                            widget.controller,
                            logoSize: logoSize,
                            onBack: widget.onBack,
                            onBackToLogin:
                            widget.onBackToLogin,
                            onSubmit: _submitRequest,
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

class _RequestContent extends StatelessWidget {
  const _RequestContent({
    required this.formKey,
    required this.identityController,
    required this.controller,
    required this.logoSize,
    required this.onBack,
    required this.onBackToLogin,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController identityController;

  final ForgotPasswordController controller;

  final double logoSize;

  final VoidCallback onBack;
  final VoidCallback onBackToLogin;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        //
        // BACK BUTTON
        //
        _BackButton(
          onPressed: onBack,
        ),

        const SizedBox(height: 8),

        //
        // FORGOT PASSWORD LOGO
        //
        ForgotPasswordLogo(
          size: logoSize,
        ),

        const SizedBox(height: 12),

        const PasswordRecoveryProgress(
          currentStep: PasswordRecoveryStep.email,
        ),

        const SizedBox(height: 24),

        //
        // TITLE
        //
        const Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 9),

        //
        // SUBTITLE
        //
        Text(
          'Enter your registered email or mobile '
              'number and we will send you a secure '
              'verification code.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(
              alpha: 0.78,
            ),
            height: 1.5,
            fontSize: 13.5,
          ),
        ),

        const SizedBox(height: 27),

        //
        // GLASS FORM CARD
        //
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            18,
            23,
            18,
            21,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const _RecoveryTitle(),

                const SizedBox(height: 20),

                //
                // EMAIL / MOBILE INPUT
                //
                AuthTextField(
                  controller: identityController,
                  label: 'Email or mobile number',
                  hintText: 'example@email.com',
                  prefixIcon:
                  Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  textInputAction:
                  TextInputAction.done,
                  autofillHints: const <String>[
                    AutofillHints.username,
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  validator:
                  ForgotPasswordValidator
                      .validateIdentity,
                  onChanged: (
                      String value,
                      ) {
                    controller.clearError();
                  },
                  onSubmitted: (
                      String value,
                      ) {
                    onSubmit();
                  },
                ),

                //
                // ERROR MESSAGE
                //
                if (controller.errorMessage !=
                    null) ...<Widget>[
                  const SizedBox(height: 14),
                  _ForgotPasswordError(
                    message:
                    controller.errorMessage!,
                  ),
                ],

                const SizedBox(height: 20),

                //
                // SEND OTP BUTTON
                //
                GlassActionButton(
                  label: 'Send Verification Code',
                  icon:
                  Icons.arrow_forward_rounded,
                  isLoading: controller.isLoading,
                  onPressed:
                  controller.isLoading
                      ? null
                      : onSubmit,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        //
        // BACK TO LOGIN
        //
        Text(
          'Remember your password?',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(
              alpha: 0.72,
            ),
            fontSize: 13,
          ),
        ),

        TextButton(
          onPressed: onBackToLogin,
          child: const Text(
            'Back to Login',
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

class _RecoveryTitle extends StatelessWidget {
  const _RecoveryTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.blue,
                AppColors.violet,
                AppColors.pink,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                AppColors.violet.withValues(
                  alpha: 0.30,
                ),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.white,
            size: 23,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Recover your account',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'We will send a secure verification code.',
                style: TextStyle(
                  color: AppColors.textSecondary
                      .withValues(
                    alpha: 0.67,
                  ),
                  fontSize: 11.5,
                ),
              ),
            ],
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
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor:
          AppColors.white.withValues(
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
    );
  }
}

class _ForgotPasswordError
    extends StatelessWidget {
  const _ForgotPasswordError({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6680)
            .withValues(
          alpha: 0.13,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFF8A9B)
              .withValues(
            alpha: 0.50,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFFB3BE),
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFD6DC),
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
