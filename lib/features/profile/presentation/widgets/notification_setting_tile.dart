import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotificationSettingTile extends StatelessWidget {
  const NotificationSettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isSaving = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isSaving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.blue,
              ),
            )
          else
            Switch(
              value: value,
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.blue,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}
