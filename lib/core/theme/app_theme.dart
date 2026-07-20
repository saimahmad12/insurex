import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      splashColor: AppColors.white.withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}