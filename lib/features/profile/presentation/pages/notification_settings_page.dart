import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/notification_preferences_controller.dart';
import '../../domain/entities/notification_preferences.dart';
import '../widgets/notification_setting_tile.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final NotificationPreferencesController controller;
  final VoidCallback onBack;

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
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
                          title: 'Notifications',
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
        key: Key('notification_preferences_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    final NotificationPreferences? preferences = widget.controller.preferences;
    if (widget.controller.loadStatus ==
            NotificationPreferencesLoadStatus.failure ||
        preferences == null) {
      return ProfileStateMessage(
        key: const Key('notification_preferences_error'),
        icon: Icons.error_outline_rounded,
        title: 'Notification settings unavailable',
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
                  key: const Key('notification_preferences_card'),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: NotificationPreference.values.map((
                      NotificationPreference preference,
                    ) {
                      return NotificationSettingTile(
                        key: ValueKey<String>(
                          'notification_${preference.name}',
                        ),
                        title: _title(preference),
                        subtitle: _subtitle(preference),
                        value: preferences.valueFor(preference),
                        isSaving: widget.controller.isSaving(preference),
                        onChanged: (bool value) {
                          widget.controller.updatePreference(preference, value);
                        },
                      );
                    }).toList(),
                  ),
                ),
                if (widget.controller.updateErrorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.updateErrorMessage!,
                    key: const Key('notification_preference_update_error'),
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

  static String _title(NotificationPreference preference) {
    return switch (preference) {
      NotificationPreference.claimStatusUpdates => 'Claim status updates',
      NotificationPreference.aiAnalysisCompletion => 'AI-analysis completion',
      NotificationPreference.additionalEvidenceRequests =>
        'Additional-evidence requests',
      NotificationPreference.claimDecisions => 'Claim decisions',
      NotificationPreference.paymentUpdates => 'Payment and payout updates',
      NotificationPreference.policyExpiryReminders => 'Policy-expiry reminders',
      NotificationPreference.securityAlerts => 'Security alerts',
      NotificationPreference.promotionalNotifications =>
        'Promotional notifications',
    };
  }

  static String _subtitle(NotificationPreference preference) {
    return switch (preference) {
      NotificationPreference.claimStatusUpdates =>
        'Updates when your claim moves to a new stage',
      NotificationPreference.aiAnalysisCompletion =>
        'Results when automated evidence analysis completes',
      NotificationPreference.additionalEvidenceRequests =>
        'Requests for more claim information',
      NotificationPreference.claimDecisions =>
        'Approval or rejection notifications',
      NotificationPreference.paymentUpdates =>
        'Payout verification, processing, and settlement',
      NotificationPreference.policyExpiryReminders =>
        'Reminders before your coverage expires',
      NotificationPreference.securityAlerts =>
        'Important account and session alerts',
      NotificationPreference.promotionalNotifications =>
        'Optional InsureX offers and announcements',
    };
  }
}
