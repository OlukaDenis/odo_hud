import 'package:flutter/material.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../models/telemetry_state.dart';
import 'metric_card.dart';

class AuxiliaryGrid extends StatelessWidget {
  final TelemetryState telemetry;
  final HudTheme theme;
  final bool isMetric;

  const AuxiliaryGrid({
    super.key,
    required this.telemetry,
    required this.theme,
    required this.isMetric,
  });

  @override
  Widget build(BuildContext context) {
    final tripDist = isMetric
        ? telemetry.tripDistanceKm.toStringAsFixed(1)
        : telemetry.tripDistanceMiles.toStringAsFixed(1);
    final tripDistUnit = isMetric ? 'KM' : 'MI';

    final avgSpeed = isMetric
        ? telemetry.averageSpeedKmh.toStringAsFixed(0)
        : UnitConverter.kmhToMph(telemetry.averageSpeedKmh).toStringAsFixed(0);
    final avgSpeedUnit = isMetric ? 'KM/H' : 'MPH';

    final movingTime =
        UnitConverter.formatMovingTime(telemetry.movingTimeSeconds);
    final heading =
        '${telemetry.cardinalDirection} ${telemetry.headingDegrees.toStringAsFixed(0)}°';

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: (constraints.maxWidth / 2) /
              ((constraints.maxHeight - 24) / 2).clamp(40.0, 300.0),
          children: [
            MetricCard(
              label: 'TRIP DISTANCE',
              value: tripDist,
              unit: tripDistUnit,
              icon: Icons.route_outlined,
              theme: theme,
            ),
            MetricCard(
              label: 'MOVING TIME',
              value: movingTime,
              icon: Icons.timer_outlined,
              theme: theme,
            ),
            MetricCard(
              label: 'AVG SPEED',
              value: avgSpeed,
              unit: avgSpeedUnit,
              icon: Icons.speed_outlined,
              theme: theme,
            ),
            MetricCard(
              label: 'HEADING',
              value: heading,
              icon: Icons.explore_outlined,
              theme: theme,
            ),
          ],
        );
      },
    );
  }
}
