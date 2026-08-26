import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/claim_timeline_event.dart';
import 'claim_formatters.dart';

class ClaimProgressTimeline extends StatelessWidget {
  const ClaimProgressTimeline({required this.events, super.key});

  final List<ClaimTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      key: const Key('claim_progress_timeline'),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(
        children: <Widget>[
          for (int index = 0; index < events.length; index++)
            _TimelineItem(
              event: events[index],
              showConnector: index < events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.showConnector});

  final ClaimTimelineEvent event;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final bool completed = event.state == ClaimTimelineEventState.completed;
    final bool current = event.state == ClaimTimelineEventState.current;
    final Color color = completed
        ? const Color(0xFF49E6A4)
        : current
        ? AppColors.blue
        : AppColors.textSecondary.withValues(alpha: 0.30);

    return Semantics(
      label:
          '${event.title}, ${event.state.name}${event.occurredAt == null ? '' : ', ${ClaimFormatters.dateTime(event.occurredAt!)}'}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 32,
            child: Column(
              children: <Widget>[
                Container(
                  key: ValueKey<String>(
                    'timeline_${event.state.name}_${event.stage.name}',
                  ),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: current ? 0.20 : 0.12),
                    border: Border.all(color: color, width: current ? 2 : 1.3),
                    boxShadow: current
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AppColors.violet.withValues(alpha: 0.45),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF49E6A4),
                          size: 17,
                        )
                      : current
                      ? const Icon(Icons.circle, color: AppColors.blue, size: 9)
                      : null,
                ),
                if (showConnector)
                  Container(
                    width: 1.5,
                    height: event.occurredAt == null ? 34 : 48,
                    color: color.withValues(alpha: completed ? 0.58 : 0.20),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: showConnector ? 16 : 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: TextStyle(
                      color: current
                          ? AppColors.white
                          : completed
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.42),
                      fontSize: 13,
                      fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (event.occurredAt != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      ClaimFormatters.dateTime(event.occurredAt!),
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.48),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
