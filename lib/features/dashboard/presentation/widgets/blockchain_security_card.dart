import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class BlockchainSecurityCard extends StatelessWidget {
  const BlockchainSecurityCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your policies are',
                  style: TextStyle(
                    color:
                    AppColors.textSecondary
                        .withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Secure',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const Text(
                  'on Blockchain',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          _BlockchainGraphic(),
        ],
      ),
    );
  }
}

class _BlockchainGraphic extends StatelessWidget {
  const _BlockchainGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.blue,
                  AppColors.violet,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                  AppColors.blue.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 28,
                ),
              ],
            ),
            child: const Icon(
              Icons.hub_outlined,
              color: AppColors.white,
              size: 35,
            ),
          ),

          Positioned(
            left: 3,
            bottom: 7,
            child: _MiniBlock(
              icon: Icons.link_rounded,
            ),
          ),

          Positioned(
            right: 2,
            bottom: 8,
            child: _MiniBlock(
              icon: Icons.shield_outlined,
            ),
          ),

          Positioned(
            top: 0,
            right: 8,
            child: _MiniBlock(
              icon: Icons.check_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBlock extends StatelessWidget {
  const _MiniBlock({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(9),
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.blue,
            AppColors.violet,
          ],
        ),
        border: Border.all(
          color: AppColors.white.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.white,
        size: 15,
      ),
    );
  }
}