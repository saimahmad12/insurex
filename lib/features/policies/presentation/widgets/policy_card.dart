import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/insurance_policy.dart';

class PolicyCard extends StatelessWidget {
  const PolicyCard({required this.policy, required this.onTap, super.key});

  final InsurancePolicy policy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PolicyIcon(type: policy.type),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        policy.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _typeSubtitle(policy.type),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                _StatusBadge(status: policy.status),
              ],
            ),

            const SizedBox(height: 20),

            _InformationRow(label: 'Policy No.', value: policy.policyNumber),

            const SizedBox(height: 13),

            _InformationRow(
              label: 'Valid Till',
              value: _formatDate(policy.validTill),
            ),

            const SizedBox(height: 13),

            _InformationRow(
              label: 'Premium',
              value: 'Rs. ${_formatAmount(policy.premium)}',
              highlightValue: true,
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),

            const SizedBox(height: 13),

            Row(
              children: <Widget>[
                Text(
                  'View Policy Details',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF815CFF),
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _typeSubtitle(PolicyType type) {
    switch (type) {
      case PolicyType.vehicle:
        return 'Vehicle Protection';

      case PolicyType.health:
        return 'Health Protection';

      case PolicyType.travel:
        return 'Travel Protection';

      case PolicyType.life:
        return 'Life Protection';

      case PolicyType.property:
        return 'Property Protection';
    }
  }

  static String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  static String _formatAmount(double amount) {
    final String value = amount.toStringAsFixed(0);

    return value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}

class _PolicyIcon extends StatelessWidget {
  const _PolicyIcon({required this.type});

  final PolicyType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors(type),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _gradientColors(type).last.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(_iconForType(type), color: Colors.white, size: 25),
    );
  }

  static IconData _iconForType(PolicyType type) {
    switch (type) {
      case PolicyType.vehicle:
        return Icons.directions_car_outlined;

      case PolicyType.health:
        return Icons.favorite_border_rounded;

      case PolicyType.travel:
        return Icons.flight_takeoff_rounded;

      case PolicyType.life:
        return Icons.volunteer_activism_outlined;

      case PolicyType.property:
        return Icons.home_work_outlined;
    }
  }

  static List<Color> _gradientColors(PolicyType type) {
    switch (type) {
      case PolicyType.vehicle:
        return const <Color>[Color(0xFF42B8FF), Color(0xFF4F74FF)];

      case PolicyType.health:
        return const <Color>[Color(0xFFFF638C), Color(0xFFE25AF5)];

      case PolicyType.travel:
        return const <Color>[Color(0xFF815CFF), Color(0xFFE25AF5)];

      case PolicyType.life:
        return const <Color>[Color(0xFFFF638C), Color(0xFF815CFF)];

      case PolicyType.property:
        return const <Color>[Color(0xFF49E6A4), Color(0xFF42B8FF)];
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PolicyStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      PolicyStatus.active => const Color(0xFF49E6A4),
      PolicyStatus.pending => const Color(0xFFFFC857),
      PolicyStatus.expired => const Color(0xFFFF718A),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),

          const SizedBox(width: 6),

          Text(
            switch (status) {
              PolicyStatus.active => 'Active',
              PolicyStatus.pending => 'Pending',
              PolicyStatus.expired => 'Expired',
            },
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
    this.highlightValue = false,
  });

  final String label;
  final String value;
  final bool highlightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color: highlightValue
                ? const Color(0xFF42B8FF)
                : Colors.white.withValues(alpha: 0.88),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
