import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/policy_details.dart';

class PolicyInformationCard extends StatelessWidget {
  const PolicyInformationCard({
    required this.details,
    super.key,
  });

  final PolicyDetails details;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          _InformationRow(
            icon: Icons.shield_outlined,
            label: 'Coverage',
            value: details.coverage,
          ),

          _divider(),

          _InformationRow(
            icon: Icons.info_outline_rounded,
            label: details.primaryLabel,
            value: details.primaryValue,
          ),

          _divider(),

          _InformationRow(
            icon: Icons.badge_outlined,
            label: details.secondaryLabel,
            value: details.secondaryValue,
          ),

          _divider(),

          _InformationRow(
            icon: Icons.verified_user_outlined,
            label: details.tertiaryLabel,
            value: details.tertiaryValue,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Divider(
        height: 1,
        color:
        Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.12),
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.blue,
            size: 20,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: Colors.black
                      .withValues(alpha: 0.48),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
