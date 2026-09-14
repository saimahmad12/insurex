import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../widgets/profile_page_header.dart';

enum LegalPlaceholderType { privacyPolicy, termsAndConditions }

class LegalPlaceholderPage extends StatelessWidget {
  const LegalPlaceholderPage({
    required this.type,
    required this.onBack,
    super.key,
  });

  final LegalPlaceholderType type;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final String title = type == LegalPlaceholderType.privacyPolicy
        ? 'Privacy Policy'
        : 'Terms and Conditions';
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
                      ProfilePageHeader(title: title, onBack: onBack),
                      const SizedBox(height: 22),
                      GlassContainer(
                        key: ValueKey<String>('legal_${type.name}'),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              type == LegalPlaceholderType.privacyPolicy
                                  ? Icons.privacy_tip_outlined
                                  : Icons.gavel_outlined,
                              color: AppColors.blue,
                              size: 40,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '$title content is being prepared.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              'Final legal content will be added later. This placeholder does not create or describe any legal commitment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 11,
                                height: 1.45,
                              ),
                            ),
                          ],
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
