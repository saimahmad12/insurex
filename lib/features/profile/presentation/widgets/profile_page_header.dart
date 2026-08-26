import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({
    required this.title,
    this.onBack,
    this.onRefresh,
    this.isRefreshing = false,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (onBack == null)
          const SizedBox(width: 44, height: 44)
        else
          _HeaderButton(
            key: const Key('profile_page_back_button'),
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: onBack,
          ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (onRefresh == null)
          const SizedBox(width: 44, height: 44)
        else
          _HeaderButton(
            key: const Key('profile_refresh_button'),
            icon: Icons.refresh_rounded,
            onPressed: isRefreshing ? null : onRefresh,
            isLoading: isRefreshing,
          ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(13),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.blue,
              ),
            )
          : IconButton(
              onPressed: onPressed,
              icon: Icon(icon, color: AppColors.white, size: 20),
            ),
    );
  }
}
