import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class SplashDescriptionCard extends StatelessWidget {
  const SplashDescriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        20,
        22,
        18,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Smarter Insurance for a Better Tomorrow',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'AI-powered fraud detection with secure '
                'blockchain-based claim processing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(
                alpha: 0.88,
              ),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 22,
            runSpacing: 10,
            children: <Widget>[
              _FeatureLabel(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Powered',
              ),
              _FeatureLabel(
                icon: Icons.hub_outlined,
                label: 'Blockchain',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureLabel extends StatelessWidget {
  const _FeatureLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          color: AppColors.blue,
          size: 18,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
