import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    required this.value,
    required this.onChanged,
    super.key,
    this.showError = false,
    this.onTermsPressed,
    this.onPrivacyPressed,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showError;
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Transform.translate(
              offset: const Offset(-8, -5),
              child: Checkbox(
                value: value,
                activeColor: AppColors.violet,
                checkColor: AppColors.white,
                side: BorderSide(
                  color: showError
                      ? const Color(0xFFFF8A9B)
                      : AppColors.white.withValues(
                    alpha: 0.45,
                  ),
                ),
                onChanged: (bool? newValue) {
                  onChanged(newValue ?? false);
                },
              ),
            ),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'I agree to the ',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  _AgreementLink(
                    label: 'Terms of Service',
                    onPressed: onTermsPressed,
                  ),
                  Text(
                    ' and ',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 12,
                    ),
                  ),
                  _AgreementLink(
                    label: 'Privacy Policy',
                    onPressed: onPrivacyPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(
              left: 42,
              top: 2,
            ),
            child: Text(
              'You must accept the terms to continue.',
              style: TextStyle(
                color: Color(0xFFFFB3BE),
                fontSize: 11.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _AgreementLink extends StatelessWidget {
  const _AgreementLink({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}