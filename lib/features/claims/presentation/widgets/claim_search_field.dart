import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ClaimSearchField extends StatelessWidget {
  const ClaimSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('claim_search_field'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search claims',
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.45),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary.withValues(alpha: 0.65),
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                key: const Key('clear_claim_search'),
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onClear();
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.white.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blue),
        ),
      ),
    );
  }
}
