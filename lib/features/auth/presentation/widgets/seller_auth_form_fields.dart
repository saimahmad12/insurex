import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/seller_registration.dart';
import 'terms_agreement.dart';

extension InsuranceCategoryPresentation on InsuranceCategory {
  String get label => switch (this) {
    InsuranceCategory.health => 'Health',
    InsuranceCategory.life => 'Life',
    InsuranceCategory.vehicle => 'Vehicle',
    InsuranceCategory.property => 'Property',
    InsuranceCategory.travel => 'Travel',
    InsuranceCategory.agriculture => 'Agriculture',
  };
}

extension RepresentativeDesignationPresentation on RepresentativeDesignation {
  String get label => switch (this) {
    RepresentativeDesignation.chiefExecutiveOfficer =>
      'Chief Executive Officer',
    RepresentativeDesignation.managingDirector => 'Managing Director',
    RepresentativeDesignation.director => 'Director',
    RepresentativeDesignation.authorizedOfficer => 'Authorized Officer',
    RepresentativeDesignation.complianceOfficer => 'Compliance Officer',
  };
}

class AuthDropdownField<T> extends StatelessWidget {
  const AuthDropdownField({
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    super.key,
    this.errorText,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.backgroundMiddle,
      iconEnabledColor: AppColors.textSecondary,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.78),
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.48),
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 21),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.075),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: _border(AppColors.white.withValues(alpha: 0.26)),
        focusedBorder: _border(
          AppColors.blue.withValues(alpha: 0.88),
          width: 1.35,
        ),
        errorBorder: _border(const Color(0xFFFF8A9B)),
        focusedErrorBorder: _border(const Color(0xFFFF8A9B), width: 1.35),
        errorStyle: const TextStyle(color: Color(0xFFFFB3BE), fontSize: 11.5),
      ),
      items: items
          .map(
            (T item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class InsuranceCategorySelector extends StatelessWidget {
  const InsuranceCategorySelector({
    required this.selectedCategories,
    required this.onToggle,
    super.key,
    this.errorText,
    this.enabled = true,
  });

  final Set<InsuranceCategory> selectedCategories;
  final ValueChanged<InsuranceCategory> onToggle;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Supported insurance categories',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: InsuranceCategory.values.map((InsuranceCategory category) {
            final bool selected = selectedCategories.contains(category);
            return FilterChip(
              key: ValueKey<String>('seller_category_${category.name}'),
              label: Text(category.label),
              selected: selected,
              onSelected: enabled ? (_) => onToggle(category) : null,
              selectedColor: AppColors.violet.withValues(alpha: 0.42),
              backgroundColor: AppColors.white.withValues(alpha: 0.075),
              checkmarkColor: AppColors.white,
              side: BorderSide(
                color: selected
                    ? AppColors.blue.withValues(alpha: 0.75)
                    : AppColors.white.withValues(alpha: 0.24),
              ),
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: Color(0xFFFFB3BE), fontSize: 11.5),
            ),
          ),
      ],
    );
  }
}

class SellerTermsDeclarations extends StatelessWidget {
  const SellerTermsDeclarations({
    required this.acceptedTerms,
    required this.confirmedDeclarations,
    required this.onTermsChanged,
    required this.onDeclarationsChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
    this.termsError,
    this.declarationsError,
    this.enabled = true,
  });

  final bool acceptedTerms;
  final bool confirmedDeclarations;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onDeclarationsChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  final String? termsError;
  final String? declarationsError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        IgnorePointer(
          ignoring: !enabled,
          child: TermsAgreement(
            key: const Key('seller_terms_agreement'),
            value: acceptedTerms,
            showError: termsError != null,
            onChanged: onTermsChanged,
            onTermsPressed: onTermsPressed,
            onPrivacyPressed: onPrivacyPressed,
          ),
        ),
        CheckboxListTile(
          key: const Key('seller_declarations_checkbox'),
          value: confirmedDeclarations,
          enabled: enabled,
          onChanged: (bool? value) {
            onDeclarationsChanged(value ?? false);
          },
          activeColor: AppColors.violet,
          checkColor: AppColors.white,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'I confirm that I am authorized to register this company and that the information provided is accurate.',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.82),
              fontSize: 12,
            ),
          ),
          side: BorderSide(
            color: declarationsError != null
                ? const Color(0xFFFF8A9B)
                : AppColors.white.withValues(alpha: 0.45),
          ),
        ),
        if (declarationsError != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                declarationsError!,
                style: const TextStyle(
                  color: Color(0xFFFFB3BE),
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SellerAuthMessage extends StatelessWidget {
  const SellerAuthMessage({
    required this.message,
    super.key,
    this.isError = true,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color accent = isError ? const Color(0xFFFF8A9B) : AppColors.blue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withValues(alpha: 0.50)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 19,
            color: isError ? const Color(0xFFFFB3BE) : AppColors.blue,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? const Color(0xFFFFD6DC) : AppColors.white,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
