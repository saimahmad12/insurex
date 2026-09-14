import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class BlockchainStatusCard extends StatelessWidget {
  const BlockchainStatusCard({
    required this.verified,
    required this.transactionHash,
    super.key,
  });

  final bool verified;
  final String transactionHash;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppColors.blue,
                      AppColors.blue,
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Blockchain Status',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Policy integrity verification',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                verified
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: verified
                    ? const Color(0xFF49E6A4)
                    : const Color(0xFFFFB84A),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF49E6A4)
                  .withValues(alpha: 0.07),
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF49E6A4)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF49E6A4),
                  size: 18,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    verified
                        ? 'Stored securely on blockchain'
                        : 'Blockchain verification pending',
                    style: const TextStyle(
                      color: Color(0xFF49E6A4),
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Transaction Hash',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            transactionHash,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
