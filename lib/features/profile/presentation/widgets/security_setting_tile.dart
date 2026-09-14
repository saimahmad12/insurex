import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SecuritySettingTile extends StatelessWidget {
  const SecuritySettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onPressed,
    this.toggleValue,
    this.onToggle,
    this.isSaving = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.blue, size: 21),
              const SizedBox(width: 12),
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
              const SizedBox(width: 10),
              if (isSaving)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.blue,
                  ),
                )
              else if (toggleValue != null && onToggle != null)
                Switch(
                  value: toggleValue!,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.blue,
                  onChanged: onToggle,
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
