import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileReadOnlyField extends StatelessWidget {
  const ProfileReadOnlyField({
    required this.value,
    required this.label,
    required this.prefixIcon,
    this.statusLabel = 'Locked',
    this.actionLabel,
    this.actionKey,
    this.onAction,
    super.key,
  });

  final String value;
  final String label;
  final IconData prefixIcon;
  final String statusLabel;
  final String? actionLabel;
  final Key? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      canRequestFocus: false,
      showCursor: false,
      enableInteractiveSelection: false,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.78),
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 21),
        suffixIcon: actionLabel == null
            ? Tooltip(
                message: statusLabel,
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 19,
                ),
              )
            : TextButton(
                key: actionKey,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
        suffixIconConstraints: actionLabel == null
            ? null
            : const BoxConstraints(minWidth: 88, minHeight: 48),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.075),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: _createBorder(AppColors.white.withValues(alpha: 0.26)),
        focusedBorder: _createBorder(AppColors.white.withValues(alpha: 0.26)),
      ),
    );
  }

  OutlineInputBorder _createBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: color),
    );
  }
}
