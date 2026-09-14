import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DashboardBottomNavigation extends StatelessWidget {
  const DashboardBottomNavigation({
    required this.selectedIndex,
    required this.onHome,
    required this.onPolicies,
    required this.onAddClaim,
    required this.onClaims,
    required this.onProfile,
    super.key,
  });

  final int selectedIndex;
  final VoidCallback onHome;
  final VoidCallback onPolicies;
  final VoidCallback onAddClaim;
  final VoidCallback onClaims;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151E42),
        border: Border(
          top: BorderSide(color: AppColors.white.withValues(alpha: 0.12)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: <Widget>[
              _NavigationItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onPressed: onHome,
              ),

              _NavigationItem(
                icon: Icons.description_outlined,
                label: 'Policies',
                selected: selectedIndex == 1,
                onPressed: onPolicies,
              ),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: onAddClaim,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[AppColors.blue, AppColors.blue],
                        ),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.35),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.blue.withValues(alpha: 0.45),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 29,
                      ),
                    ),
                  ),
                ),
              ),

              _NavigationItem(
                icon: Icons.assignment_outlined,
                label: 'Claims',
                selected: selectedIndex == 3,
                onPressed: onClaims,
              ),

              _NavigationItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: selectedIndex == 4,
                onPressed: onProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;

  final VoidCallback onPressed;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.blue : Colors.white70;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 22),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
