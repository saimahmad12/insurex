import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/otp_verification_controller.dart';
import '../validators/otp_validator.dart';
import '../widgets/forgot_password_logo.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/password_recovery_progress.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    required this.identity,
    required this.controller,
    required this.onBack,
    required this.onVerified,
    super.key,
  });

  final String identity;

  final OtpVerificationController controller;

  final VoidCallback onBack;
  final VoidCallback onVerified;

  @override
  State<OtpVerificationPage> createState() {
    return _OtpVerificationPageState();
  }
}

class _OtpVerificationPageState
    extends State<OtpVerificationPage> {
  String _otp = '';

  Future<void> _verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final String? validationError =
    OtpValidator.validate(_otp);

    if (validationError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(validationError),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    final bool verified =
    await widget.controller.verifyOtp(
      identity: widget.identity,
      code: _otp,
    );

    if (!mounted || !verified) {
      return;
    }

    widget.onVerified();
  }

  Future<void> _resendCode() async {
    await widget.controller.resendOtp(
      identity: widget.identity,
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();

    super.dispose();
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
              (constraints.maxHeight * 0.18).clamp(
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
                      MediaQuery.viewInsetsOf(context)
                          .bottom *
                          0.12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                    constraints.maxHeight - 36,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 430,
                      ),
                      child: AnimatedBuilder(
                        animation: widget.controller,
                        builder: (
                            BuildContext context,
                            Widget? child,
                            ) {
                          return Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              _BackButton(
                                onPressed:
                                widget.onBack,
                              ),

                              const SizedBox(height: 6),

                              ForgotPasswordLogo(
                                size: logoSize,
                              ),

                              const SizedBox(height: 12),

                              const PasswordRecoveryProgress(
                                currentStep:
                                PasswordRecoveryStep.code,
                              ),

                              const SizedBox(height: 24),

                              const Text(
                                'Verify Your Code',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color:
                                  Colors.black87,
                                  fontSize: 29,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Enter the 6-digit verification '
                                    'code sent to',
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.76,
                                  ),
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _maskIdentity(
                                  widget.identity,
                                ),
                                textAlign:
                                TextAlign.center,
                                style: const TextStyle(
                                  color:
                                  AppColors.blue,
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 25),

                              GlassContainer(
                                width:
                                double.infinity,
                                padding:
                                const EdgeInsets
                                    .fromLTRB(
                                  18,
                                  24,
                                  18,
                                  21,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    const _VerificationIcon(),

                                    const SizedBox(
                                      height: 21,
                                    ),

                                    OtpCodeField(
                                      onChanged: (
                                          String value,
                                          ) {
                                        setState(() {
                                          _otp = value;
                                        });

                                        widget.controller
                                            .clearMessage();
                                      },
                                    ),

                                    if (widget.controller
                                        .errorMessage !=
                                        null) ...<Widget>[
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      _MessageBox(
                                        message: widget
                                            .controller
                                            .errorMessage!,
                                        isError: true,
                                      ),
                                    ],

                                    if (widget.controller
                                        .successMessage !=
                                        null) ...<Widget>[
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      _MessageBox(
                                        message: widget
                                            .controller
                                            .successMessage!,
                                        isError: false,
                                      ),
                                    ],

                                    const SizedBox(
                                      height: 21,
                                    ),

                                    GlassActionButton(
                                      label:
                                      'Verify Code',
                                      icon: Icons
                                          .verified_rounded,
                                      isLoading: widget
                                          .controller
                                          .isVerifying,
                                      onPressed: widget
                                          .controller
                                          .isVerifying
                                          ? null
                                          : _verifyOtp,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 21),

                              Text(
                                "Didn't receive the code?",
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.72,
                                  ),
                                  fontSize: 13,
                                ),
                              ),

                              TextButton(
                                onPressed: widget
                                    .controller
                                    .isResending
                                    ? null
                                    : _resendCode,
                                child: widget.controller
                                    .isResending
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2,
                                    color:
                                    AppColors
                                        .pink,
                                  ),
                                )
                                    : const Text(
                                  'Resend Code',
                                  style:
                                  TextStyle(
                                    color:
                                    AppColors
                                        .pink,
                                    fontWeight:
                                    FontWeight
                                        .w800,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              TextButton.icon(
                                onPressed:
                                widget.onBack,
                                icon: const Icon(
                                  Icons
                                      .edit_outlined,
                                  size: 17,
                                  color: AppColors
                                      .textSecondary,
                                ),
                                label: const Text(
                                  'Change email or mobile number',
                                  style: TextStyle(
                                    color: AppColors
                                        .textSecondary,
                                    fontSize: 12,
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

  String _maskIdentity(String value) {
    final String identity = value.trim();

    if (identity.contains('@')) {
      final List<String> parts =
      identity.split('@');

      if (parts.length != 2) {
        return identity;
      }

      final String name = parts.first;

      if (name.length <= 2) {
        return '$name@${parts.last}';
      }

      return '${name.substring(0, 2)}***@${parts.last}';
    }

    final String digits =
    identity.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.length <= 4) {
      return identity;
    }

    return '******${digits.substring(
      digits.length - 4,
    )}';
  }
}

class _VerificationIcon extends StatelessWidget {
  const _VerificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        gradient:
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.blue,
            AppColors.blue,
            AppColors.blue,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.blue.withValues(
              alpha: 0.33,
            ),
            blurRadius: 22,
          ),
        ],
      ),
      child: const Icon(
        Icons.verified_user_outlined,
        color: AppColors.white,
        size: 31,
      ),
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

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color color = isError
        ? const Color(0xFFFF8A9B)
        : const Color(0xFF64E3A1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(
            alpha: 0.46,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons
                .check_circle_outline_rounded,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
