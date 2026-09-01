import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../application/controllers/profile_controller.dart';
import '../../domain/entities/identity_verification.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_card.dart';
import '../widgets/profile_page_header.dart';
import '../widgets/profile_state_message.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.controller,
    required this.onEditProfile,
    required this.onIdentityVerification,
    required this.onMyPolicies,
    required this.onMyClaims,
    required this.onPayments,
    required this.onPayoutMethods,
    required this.onSecurity,
    required this.onNotifications,
    required this.onHelpSupport,
    required this.onPrivacyPolicy,
    required this.onTermsAndConditions,
    required this.onLogoutSuccess,
    super.key,
  });

  final ProfileController controller;
  final Future<UserProfile?> Function(UserProfile profile) onEditProfile;
  final Future<IdentityVerification?> Function() onIdentityVerification;
  final VoidCallback onMyPolicies;
  final VoidCallback onMyClaims;
  final VoidCallback onPayments;
  final VoidCallback onPayoutMethods;
  final VoidCallback onSecurity;
  final VoidCallback onNotifications;
  final VoidCallback onHelpSupport;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsAndConditions;
  final VoidCallback onLogoutSuccess;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isOpeningEditProfile = false;
  bool _isOpeningIdentityVerification = false;

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
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
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
                          title: 'Profile',
                          onRefresh: widget.controller.profile == null
                              ? null
                              : widget.controller.refresh,
                          isRefreshing: widget.controller.isRefreshing,
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
    if (widget.controller.isInitialLoading) {
      return const Center(
        key: Key('profile_initial_loading'),
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    if (widget.controller.loadStatus == ProfileLoadStatus.failure &&
        widget.controller.profile == null) {
      return ProfileStateMessage(
        key: const Key('profile_load_error'),
        icon: Icons.error_outline_rounded,
        title: 'Unable to load profile',
        message: widget.controller.errorMessage ?? 'Please try again.',
        actionLabel: 'Try Again',
        onAction: widget.controller.retry,
      );
    }
    final UserProfile? profile = widget.controller.profile;
    if (widget.controller.loadStatus == ProfileLoadStatus.empty ||
        profile == null) {
      return const ProfileStateMessage(
        key: Key('profile_empty'),
        icon: Icons.person_off_outlined,
        title: 'Profile unavailable',
        message: 'Your account profile could not be found.',
      );
    }

    return RefreshIndicator(
      key: const Key('profile_refresh_indicator'),
      color: AppColors.blue,
      onRefresh: widget.controller.refresh,
      child: ListView(
        key: const PageStorageKey<String>('profile_scroll_view'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.controller.refreshErrorMessage !=
                      null) ...<Widget>[
                    Text(
                      widget.controller.refreshErrorMessage!,
                      key: const Key('profile_refresh_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFB3BE),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ProfileHeader(
                    profile: profile,
                    onSettings: widget.onSecurity,
                  ),
                  const SizedBox(height: 18),
                  ProfileMenuCard(
                    key: const Key('profile_account_menu'),
                    children: <Widget>[
                      ProfileMenuItem(
                        key: const Key('profile_personal_information'),
                        title: 'Personal Information',
                        subtitle: 'View and update your account details',
                        icon: Icons.person_outline_rounded,
                        onPressed: () {
                          _editProfile(profile);
                        },
                      ),
                      ProfileMenuItem(
                        key: const Key('profile_identity_verification'),
                        title: 'Identity Verification',
                        subtitle: 'Status and masked identity information',
                        icon: Icons.verified_user_outlined,
                        onPressed: _openIdentityVerification,
                      ),
                      ProfileMenuItem(
                        title: 'My Policies',
                        icon: Icons.description_outlined,
                        onPressed: widget.onMyPolicies,
                      ),
                      ProfileMenuItem(
                        title: 'My Claims',
                        icon: Icons.assignment_outlined,
                        onPressed: widget.onMyClaims,
                      ),
                      ProfileMenuItem(
                        title: 'Payments',
                        icon: Icons.account_balance_wallet_outlined,
                        onPressed: widget.onPayments,
                      ),
                      ProfileMenuItem(
                        key: const Key('profile_saved_payout_methods'),
                        title: 'Saved Payout Methods',
                        icon: Icons.account_balance_outlined,
                        onPressed: widget.onPayoutMethods,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ProfileMenuCard(
                    children: <Widget>[
                      ProfileMenuItem(
                        title: 'Security',
                        icon: Icons.lock_outline_rounded,
                        onPressed: widget.onSecurity,
                      ),
                      ProfileMenuItem(
                        title: 'Notifications',
                        icon: Icons.notifications_outlined,
                        onPressed: widget.onNotifications,
                      ),
                      ProfileMenuItem(
                        title: 'Help and Support',
                        icon: Icons.support_agent_rounded,
                        onPressed: widget.onHelpSupport,
                      ),
                      ProfileMenuItem(
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip_outlined,
                        onPressed: widget.onPrivacyPolicy,
                      ),
                      ProfileMenuItem(
                        title: 'Terms and Conditions',
                        icon: Icons.gavel_outlined,
                        onPressed: widget.onTermsAndConditions,
                      ),
                      ProfileMenuItem(
                        key: const Key('profile_logout'),
                        title: widget.controller.isLoggingOut
                            ? 'Logging out…'
                            : 'Logout',
                        icon: Icons.logout_rounded,
                        destructive: true,
                        onPressed: widget.controller.isLoggingOut
                            ? () {}
                            : _requestLogout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(UserProfile profile) async {
    if (_isOpeningEditProfile) {
      return;
    }
    _isOpeningEditProfile = true;
    try {
      final UserProfile? updated = await widget.onEditProfile(profile);
      if (updated != null && mounted) {
        widget.controller.applyUpdatedProfile(updated);
      }
    } finally {
      _isOpeningEditProfile = false;
    }
  }

  Future<void> _openIdentityVerification() async {
    if (_isOpeningIdentityVerification) {
      return;
    }
    _isOpeningIdentityVerification = true;
    try {
      final IdentityVerification? updated = await widget
          .onIdentityVerification();
      if (updated != null && mounted) {
        if (updated.status == IdentityVerificationStatus.verified) {
          await widget.controller.refresh();
        } else {
          widget.controller.applyIdentityVerification(updated);
        }
      }
    } finally {
      _isOpeningIdentityVerification = false;
    }
  }

  Future<void> _requestLogout() async {
    final bool confirmed = await showLogoutConfirmationDialog(context);
    if (!confirmed || !mounted) {
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.logoutErrorMessage ?? 'Unable to log out.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
