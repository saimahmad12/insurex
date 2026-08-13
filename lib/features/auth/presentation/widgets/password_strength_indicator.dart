import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    required this.password,
    super.key,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final int strength = _calculateStrength(password);
    final Color activeColor = _getStrengthColor(strength);
    final String label = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: List<Widget>.generate(
            4,
                (int index) {
              final bool isActive = index < strength;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index == 3 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isActive
                        ? activeColor
                        : AppColors.white.withValues(
                      alpha: 0.14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),
        Text(
          password.isEmpty
              ? 'Use 8+ characters with letters and numbers'
              : 'Password strength: $label',
          style: TextStyle(
            color: password.isEmpty
                ? AppColors.textSecondary.withValues(
              alpha: 0.60,
            )
                : activeColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _calculateStrength(String value) {
    if (value.isEmpty) {
      return 0;
    }

    int score = 0;

    if (value.length >= 8) {
      score++;
    }

    if (RegExp('[A-Z]').hasMatch(value) &&
        RegExp('[a-z]').hasMatch(value)) {
      score++;
    }

    if (RegExp('[0-9]').hasMatch(value)) {
      score++;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(value)) {
      score++;
    }

    return score;
  }

  String _getStrengthLabel(int strength) {
    return switch (strength) {
      1 => 'Weak',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Strong',
      _ => 'Very weak',
    };
  }

  Color _getStrengthColor(int strength) {
    return switch (strength) {
      1 => const Color(0xFFFF7B8E),
      2 => const Color(0xFFFFB74D),
      3 => AppColors.blue,
      4 => const Color(0xFF64E3A1),
      _ => AppColors.textSecondary,
    };
  }
}