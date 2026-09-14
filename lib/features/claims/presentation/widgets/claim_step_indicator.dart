import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ClaimStepIndicator extends StatelessWidget {
  const ClaimStepIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Step $currentStep of $totalSteps',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.72),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 5,
            value: currentStep / totalSteps,
            backgroundColor: AppColors.white.withValues(alpha: 0.09),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        ),
      ],
    );
  }
}
