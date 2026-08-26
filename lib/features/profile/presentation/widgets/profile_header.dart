import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/user_profile.dart';
import 'identity_status_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.onSettings,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('profile_header'),
      padding: const EdgeInsets.all(19),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.blue,
                  AppColors.violet,
                  AppColors.pink,
                ],
              ),
            ),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.role,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  profile.mobileNumber,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.emailAddress,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 10),
                IdentityStatusBadge(
                  status: profile.identityVerification.status,
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('profile_settings_button'),
            tooltip: 'Security settings',
            onPressed: onSettings,
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
