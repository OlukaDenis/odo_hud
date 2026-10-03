import 'package:flutter/material.dart';
import '../../core/theme/hud_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final HudTheme theme;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.cardBorderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Label & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 12,
                    color: theme.cardLabelColor,
                    fontWeight: FontWeight.w600,
                  ).copyWith(letterSpacing: 0.3),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 14,
                  color: theme.cardLabelColor.withValues(alpha: 0.8),
                ),
              ],
            ],
          ),

          // Value and Unit
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 26,
                    color: theme.cardValueColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    unit!,
                    style: theme.getTelemetryTextStyle(
                      fontSize: 13,
                      color: theme.speedNormal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
