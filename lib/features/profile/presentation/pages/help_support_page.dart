import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../widgets/profile_menu_card.dart';
import '../widgets/profile_page_header.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({
    required this.onBack,
    required this.onAction,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ProfilePageHeader(
                        title: 'Help and Support',
                        onBack: onBack,
                      ),
                      const SizedBox(height: 22),
                      ProfileMenuCard(
                        key: const Key('help_support_menu'),
                        children: <Widget>[
                          ProfileMenuItem(
                            title: 'Frequently Asked Questions',
                            icon: Icons.quiz_outlined,
                            onPressed: () {
                              onAction('Frequently Asked Questions');
                            },
                          ),
                          ProfileMenuItem(
                            title: 'Contact Support',
                            icon: Icons.support_agent_rounded,
                            onPressed: () {
                              onAction('Contact Support');
                            },
                          ),
                          ProfileMenuItem(
                            title: 'Report a Problem',
                            icon: Icons.bug_report_outlined,
                            onPressed: () {
                              onAction('Report a Problem');
                            },
                          ),
                          ProfileMenuItem(
                            title: 'Claim Support',
                            icon: Icons.assignment_outlined,
                            onPressed: () {
                              onAction('Claim Support');
                            },
                          ),
                          ProfileMenuItem(
                            title: 'Payment Support',
                            icon: Icons.account_balance_wallet_outlined,
                            onPressed: () {
                              onAction('Payment Support');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'InsureX version 1.0.0 (1)',
                        key: Key('app_version_information'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
