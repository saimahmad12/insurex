import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.userName,
    required this.onNotifications,
    super.key,
  });

  final String userName;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Hello, $userName 👋',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            IconButton(
              tooltip: 'Notifications',
              onPressed: onNotifications,
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.black,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                AppColors.white.withValues(
                  alpha: 0.06,
                ),
                side: BorderSide(
                  color:
                  AppColors.white.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),

            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pink,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
