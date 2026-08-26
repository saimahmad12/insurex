import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/blockchain_claim_record.dart';
import 'claim_formatters.dart';

class ClaimBlockchainStatusCard extends StatelessWidget {
  const ClaimBlockchainStatusCard({
    required this.record,
    required this.onCopyTransactionHash,
    super.key,
  });

  final BlockchainClaimRecord record;
  final ValueChanged<String> onCopyTransactionHash;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claim_blockchain_status_card'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.hub_outlined, color: AppColors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Blockchain Status',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _BlockchainRow(
            label: 'Record status',
            value: ClaimFormatters.blockchainStatus(record.status),
          ),
          _BlockchainRow(
            label: 'Verification',
            value: record.verificationStatus,
          ),
          if (record.recordedAt != null)
            _BlockchainRow(
              label: 'Recorded at',
              value: ClaimFormatters.dateTime(record.recordedAt!),
            ),
          if (record.transactionHash != null) ...<Widget>[
            const SizedBox(height: 3),
            Text(
              'Transaction hash',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.52),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 5, 10),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      record.transactionHash!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('copy_claim_transaction_hash'),
                    tooltip: 'Copy transaction hash',
                    onPressed: () {
                      onCopyTransactionHash(record.transactionHash!);
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Text(
              'This record secures claim data and evidence hashes. Original images are not stored on the blockchain.',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.48),
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockchainRow extends StatelessWidget {
  const _BlockchainRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.52),
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
