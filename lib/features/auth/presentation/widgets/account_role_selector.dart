import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/account_role.dart';

class AccountRoleSelector extends StatelessWidget {
  const AccountRoleSelector({
    required this.selectedRole,
    required this.onRoleSelected,
    super.key,
    this.enabled = true,
  });

  final AccountRole selectedRole;
  final ValueChanged<AccountRole> onRoleSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Account type',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: AccountRole.values.map((AccountRole role) {
            final bool isSelected = role == selectedRole;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role == AccountRole.customer ? 6 : 0,
                  left: role == AccountRole.seller ? 6 : 0,
                ),
                child: _RoleOption(
                  key: ValueKey<String>('account_role_${role.name}'),
                  label: _labelFor(role),
                  icon: _iconFor(role),
                  isSelected: isSelected,
                  onPressed: enabled && role != selectedRole
                      ? () => onRoleSelected(role)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static String _labelFor(AccountRole role) {
    return switch (role) {
      AccountRole.customer => 'Customer',
      AccountRole.seller => 'Insurance Company',
    };
  }

  static IconData _iconFor(AccountRole role) {
    return switch (role) {
      AccountRole.customer => Icons.person_outline_rounded,
      AccountRole.seller => Icons.business_outlined,
    };
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppColors.blue.withValues(alpha: 0.85)
                : AppColors.white.withValues(alpha: 0.22),
          ),
          gradient: LinearGradient(
            colors: isSelected
                ? <Color>[
                    AppColors.electricBlue.withValues(alpha: 0.34),
                    AppColors.violet.withValues(alpha: 0.25),
                  ]
                : <Color>[
                    AppColors.white.withValues(alpha: 0.08),
                    AppColors.white.withValues(alpha: 0.035),
                  ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.blue
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.1,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
