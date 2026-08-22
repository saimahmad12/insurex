import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/insurance_policy.dart';

class PolicySummaryCard extends StatelessWidget {
  const PolicySummaryCard({
    required this.policy,
    super.key,
  });

  final InsurancePolicy policy;

  @override
  Widget build(BuildContext context) {
    final bool active =
        policy.status == PolicyStatus.active;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors(
                      policy.type,
                    ),
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Icon(
                  _policyIcon(policy.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      policy.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      policy.policyNumber,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: 0.55,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF49E6A4)
                      .withValues(alpha: 0.12)
                      : const Color(0xFFFF718A)
                      .withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  active ? 'Active' : 'Expired',
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF49E6A4)
                        : const Color(0xFFFF718A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Divider(
            color:
            Colors.white.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 12),

          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: 'Premium',
                  value:
                  'Rs. ${_formatAmount(policy.premium)}',
                ),
              ),

              Container(
                height: 38,
                width: 1,
                color: Colors.white
                    .withValues(alpha: 0.08),
              ),

              Expanded(
                child: _SummaryItem(
                  label: 'Valid Till',
                  value:
                  _formatDate(policy.validTill),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _policyIcon(
      PolicyType type,
      ) {
    switch (type) {
      case PolicyType.vehicle:
        return Icons.directions_car_outlined;

      case PolicyType.health:
        return Icons.favorite_border_rounded;

      case PolicyType.travel:
        return Icons.flight_takeoff_rounded;
    }
  }

  static List<Color> _gradientColors(
      PolicyType type,
      ) {
    switch (type) {
      case PolicyType.vehicle:
        return const <Color>[
          Color(0xFF42B8FF),
          Color(0xFF4F74FF),
        ];

      case PolicyType.health:
        return const <Color>[
          Color(0xFFFF638C),
          Color(0xFFE25AF5),
        ];

      case PolicyType.travel:
        return const <Color>[
          Color(0xFF815CFF),
          Color(0xFFE25AF5),
        ];
    }
  }

  static String _formatAmount(double amount) {
    final String value =
    amount.toStringAsFixed(0);

    return value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
    );
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
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color:
            Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}