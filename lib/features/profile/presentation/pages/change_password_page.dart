import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_action_button.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/password_strength_indicator.dart';
import '../../application/controllers/security_settings_controller.dart';
import '../../application/validators/password_validator.dart';
import '../widgets/profile_page_header.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({
    required this.controller,
    required this.onBack,
    required this.onPasswordChanged,
    super.key,
  });

  final SecuritySettingsController controller;
  final VoidCallback onBack;
  final VoidCallback onPasswordChanged;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _didReportSuccess = false;

  @override
  void dispose() {
    _clearPasswords();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ProfilePageHeader(
                            title: 'Change Password',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 22),
                          GlassContainer(
                            padding: const EdgeInsets.all(18),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  AuthTextField(
                                    key: const Key('current_password_field'),
                                    controller: _currentController,
                                    label: 'Current password',
                                    hintText: 'Enter current password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: true,
                                    validator: PasswordValidator
                                        .validateCurrentPassword,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key('new_password_field'),
                                    controller: _newController,
                                    label: 'New password',
                                    hintText: 'Create a strong password',
                                    prefixIcon: Icons.password_rounded,
                                    obscureText: true,
                                    validator:
                                        PasswordValidator.validateNewPassword,
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 9),
                                  PasswordStrengthIndicator(
                                    password: _newController.text,
                                  ),
                                  const SizedBox(height: 14),
                                  AuthTextField(
                                    key: const Key('confirm_password_field'),
                                    controller: _confirmController,
                                    label: 'Confirm new password',
                                    hintText: 'Re-enter new password',
                                    prefixIcon: Icons.lock_reset_rounded,
                                    obscureText: true,
                                    validator: (String? value) =>
                                        PasswordValidator.validateConfirmation(
                                          value,
                                          _newController.text,
                                        ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.controller.passwordErrorMessage !=
                              null) ...<Widget>[
                            const SizedBox(height: 12),
                            Text(
                              widget.controller.passwordErrorMessage!,
                              key: const Key('change_password_error'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFFB3BE),
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (widget.controller.passwordChangeStatus ==
                              PasswordChangeStatus.success) ...<Widget>[
                            const SizedBox(height: 12),
                            const Text(
                              'Password changed successfully.',
                              key: Key('change_password_success'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF49E6A4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          GlassActionButton(
                            key: const Key('change_password_button'),
                            label: 'Change Password',
                            icon: Icons.lock_reset_rounded,
                            isLoading: widget.controller.isChangingPassword,
                            onPressed: widget.controller.isChangingPassword
                                ? null
                                : _changePassword,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_didReportSuccess || _formKey.currentState?.validate() != true) {
      return;
    }
    final bool succeeded = await widget.controller.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
      confirmPassword: _confirmController.text,
    );
    if (!succeeded || !mounted) {
      return;
    }
    setState(_clearPasswords);
    if (_didReportSuccess) {
      return;
    }
    _didReportSuccess = true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    widget.onPasswordChanged();
  }

  void _clearPasswords() {
    _currentController.clear();
    _newController.clear();
    _confirmController.clear();
  }
}
