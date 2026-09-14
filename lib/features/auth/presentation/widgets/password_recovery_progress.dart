import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

enum PasswordRecoveryStep { email, code, password }

class PasswordRecoveryProgress extends StatelessWidget {
  const PasswordRecoveryProgress({required this.currentStep, super.key});

  final PasswordRecoveryStep currentStep;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('password_recovery_progress'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ProgressStep(
              step: PasswordRecoveryStep.email,
              currentStep: currentStep,
              text: 'Email',
              number: '1',
            ),
          ),
          _ProgressLine(
            from: PasswordRecoveryStep.email,
            to: PasswordRecoveryStep.code,
            completed: currentStep.index > PasswordRecoveryStep.email.index,
          ),
          Expanded(
            child: _ProgressStep(
              step: PasswordRecoveryStep.code,
              currentStep: currentStep,
              text: 'Code',
              number: '2',
            ),
          ),
          _ProgressLine(
            from: PasswordRecoveryStep.code,
            to: PasswordRecoveryStep.password,
            completed: currentStep.index > PasswordRecoveryStep.code.index,
          ),
          Expanded(
            child: _ProgressStep(
              step: PasswordRecoveryStep.password,
              currentStep: currentStep,
              text: 'Password',
              number: '3',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.step,
    required this.currentStep,
    required this.text,
    required this.number,
  });

  final PasswordRecoveryStep step;
  final PasswordRecoveryStep currentStep;
  final String text;
  final String number;

  @override
  Widget build(BuildContext context) {
    final bool completed = step.index < currentStep.index;
    final bool active = step == currentStep;
    final String state = completed
        ? 'completed'
        : active
        ? 'active'
        : 'upcoming';

    return Column(
      key: Key('password_recovery_step_${step.name}_$state'),
      children: <Widget>[
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: completed
                ? const LinearGradient(
                    colors: <Color>[AppColors.blue, AppColors.blue],
                  )
                : null,
            color: active ? AppColors.white.withValues(alpha: 0.08) : null,
            border: active ? Border.all(color: AppColors.blue, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: completed
              ? const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 18,
                )
              : Text(
                  number,
                  style: TextStyle(
                    color: active ? AppColors.blue : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            color: active || completed
                ? AppColors.blue
                : AppColors.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.from,
    required this.to,
    required this.completed,
  });

  final PasswordRecoveryStep from;
  final PasswordRecoveryStep to;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final String state = completed ? 'completed' : 'upcoming';
    return Container(
      key: Key('password_recovery_line_${from.name}_${to.name}_$state'),
      width: 28,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.blue.withValues(alpha: 0.8)
            : AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
