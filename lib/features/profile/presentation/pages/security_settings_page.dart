import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/security_settings_controller.dart';
import '../../domain/entities/security_settings.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';
import '../widgets/security_setting_tile.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({
    required this.controller,
    required this.onBack,
    required this.onChangePassword,
    required this.onPlaceholderAction,
    required this.onLogoutSuccess,
    super.key,
  });

  final SecuritySettingsController controller;
  final VoidCallback onBack;
  final VoidCallback onChangePassword;
  final ValueChanged<String> onPlaceholderAction;
  final VoidCallback onLogoutSuccess;

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
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
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: ProfilePageHeader(
                          title: 'Security',
                          onBack: widget.onBack,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.controller.isLoading) {
      return const Center(
        key: Key('security_initial_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    final SecuritySettings? settings = widget.controller.settings;
    if (widget.controller.loadStatus == SecurityLoadStatus.failure ||
        settings == null) {
      return ProfileStateMessage(
        key: const Key('security_load_error'),
        icon: Icons.error_outline_rounded,
        title: 'Security settings unavailable',
        message: widget.controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GlassContainer(
                  key: const Key('security_settings_card'),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: <Widget>[
                      SecuritySettingTile(
                        key: const Key('change_password_setting'),
                        icon: Icons.password_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onPressed: widget.onChangePassword,
                      ),
                      SecuritySettingTile(
                        key: const Key('biometric_login_setting'),
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Login',
                        subtitle: 'Use device biometrics when available',
                        toggleValue: settings.biometricLoginEnabled,
                        isSaving: widget.controller.isUpdatingSetting,
                        onToggle: widget.controller.updateBiometricLogin,
                      ),
                      SecuritySettingTile(
                        icon: Icons.phonelink_lock_outlined,
                        title: 'Two-factor authentication',
                        subtitle: settings.twoFactorAuthenticationAvailable
                            ? 'Additional sign-in verification'
                            : 'Coming with the authentication backend',
                        onPressed: () {
                          widget.onPlaceholderAction(
                            'Two-factor authentication',
                          );
                        },
                      ),
                      SecuritySettingTile(
                        icon: Icons.devices_outlined,
                        title: 'Active session',
                        subtitle: settings.activeSessionDescription,
                        onPressed: () {
                          widget.onPlaceholderAction('Active sessions');
                        },
                      ),
                      SecuritySettingTile(
                        key: const Key('security_logout_setting'),
                        icon: Icons.logout_rounded,
                        title: widget.controller.isLoggingOut
                            ? 'Logging out…'
                            : 'Logout from current session',
                        subtitle: 'End this authenticated session',
                        isSaving: widget.controller.isLoggingOut,
                        onPressed: widget.controller.isLoggingOut
                            ? null
                            : _requestLogout,
                      ),
                    ],
                  ),
                ),
                if (widget.controller.settingErrorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.settingErrorMessage!,
                    key: const Key('security_setting_error'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFB3BE),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestLogout() async {
    if (!await showLogoutConfirmationDialog(context) || !mounted) {
      return;
    }
    final bool succeeded = await widget.controller.logout();
    if (!mounted) {
      return;
    }
    if (succeeded) {
      widget.onLogoutSuccess();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.controller.logoutErrorMessage ?? 'Unable to log out.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
