import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../application/controllers/file_claim_controller.dart';
import '../../domain/entities/claim_policy.dart';
import 'claim_formatters.dart';

class PolicySelectionStep extends StatelessWidget {
  const PolicySelectionStep({
    required this.loadState,
    required this.policies,
    required this.selectedPolicy,
    required this.onSelected,
    required this.onRetry,
    super.key,
    this.errorMessage,
  });

  final ClaimPolicyLoadState loadState;
  final List<ClaimPolicy> policies;
  final ClaimPolicy? selectedPolicy;
  final ValueChanged<ClaimPolicy> onSelected;
  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (loadState == ClaimPolicyLoadState.initial ||
        loadState == ClaimPolicyLoadState.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator(color: AppColors.blue)),
      );
    }
    if (loadState == ClaimPolicyLoadState.failure) {
      return _PolicyStateCard(
        icon: Icons.error_outline_rounded,
        title: 'Policies unavailable',
        message: errorMessage ?? 'Unable to load eligible policies.',
        actionLabel: 'Try Again',
        onAction: onRetry,
      );
    }
    if (loadState == ClaimPolicyLoadState.empty) {
      return const _PolicyStateCard(
        icon: Icons.policy_outlined,
        title: 'No eligible policies',
        message: 'An active, unexpired policy is required to file a claim.',
      );
    }

    return Column(
      key: const Key('policy_selection_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Choose the active policy related to this incident.',
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.75),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        for (final ClaimPolicy policy in policies) ...<Widget>[
          _ClaimPolicyCard(
            policy: policy,
            selected: selectedPolicy?.id == policy.id,
            onTap: () => onSelected(policy),
          ),
          const SizedBox(height: 13),
        ],
      ],
    );
  }
}

class _ClaimPolicyCard extends StatelessWidget {
  const _ClaimPolicyCard({
    required this.policy,
    required this.selected,
    required this.onTap,
  });

  final ClaimPolicy policy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('claim_policy_${policy.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            GlassContainer(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: <Color>[AppColors.blue, AppColors.violet],
                          ),
                        ),
                        child: Icon(
                          _iconFor(policy.type),
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              policy.name,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              policy.policyNumber,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.62,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected
                            ? const Color(0xFF49E6A4)
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PolicyValue(label: 'Coverage', value: policy.coverageType),
                  const SizedBox(height: 9),
                  _PolicyValue(
                    label: 'Expires',
                    value: ClaimFormatters.date(policy.expiresAt),
                  ),
                  const SizedBox(height: 9),
                  _PolicyValue(
                    label: 'Coverage limit',
                    value: ClaimFormatters.amount(policy.coverageLimit),
                    highlighted: true,
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(ClaimPolicyType type) {
    switch (type) {
      case ClaimPolicyType.vehicle:
        return Icons.directions_car_outlined;
      case ClaimPolicyType.health:
        return Icons.favorite_border_rounded;
      case ClaimPolicyType.travel:
        return Icons.flight_takeoff_rounded;
    }
  }
}

class _PolicyValue extends StatelessWidget {
  const _PolicyValue({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.58),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: highlighted ? AppColors.blue : AppColors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyStateCard extends StatelessWidget {
  const _PolicyStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('policy_state_card'),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(icon, color: AppColors.blue, size: 44),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            if (onAction != null) ...<Widget>[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
