import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    required this.onPolicies,
    required this.onFileClaim,
    required this.onClaimStatus,
    required this.onPayments,
    super.key,
  });

  final VoidCallback onPolicies;
  final VoidCallback onFileClaim;
  final VoidCallback onClaimStatus;
  final VoidCallback onPayments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.18,
      children: <Widget>[
        _QuickActionItem(
          label: 'My Policies',
          icon:
          Icons.description_outlined,
          onPressed: onPolicies,
        ),

        _QuickActionItem(
          label: 'File a Claim',
          icon:
          Icons.note_add_outlined,
          onPressed: onFileClaim,
        ),

        _QuickActionItem(
          label: 'Claim Status',
          icon:
          Icons.lock_clock_outlined,
          onPressed: onClaimStatus,
        ),

        _QuickActionItem(
          label: 'Payments',
          icon:
          Icons.money_rounded,
          onPressed: onPayments,
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(18),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(14),
                  gradient:
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end:
                    Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.blue,
                      AppColors.blue,
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                      AppColors.blue
                          .withValues(
                        alpha: 0.30,
                      ),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 25,
                ),
              ),

              const SizedBox(height: 13),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
