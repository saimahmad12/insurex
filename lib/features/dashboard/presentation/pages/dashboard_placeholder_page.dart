import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';

class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.dashboard_rounded,
                      color: AppColors.white,
                      size: 58,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Login Successful',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The dashboard screen will be developed next.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}