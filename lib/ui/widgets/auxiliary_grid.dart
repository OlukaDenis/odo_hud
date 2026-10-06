import 'package:flutter/material.dart';

import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../models/telemetry_state.dart';
import 'compass/compass_card.dart';
import 'hud_quick_actions.dart';
import 'metric_card.dart';

class AuxiliaryGrid extends StatelessWidget {
  final TelemetryState telemetry;
  final HudTheme theme;
  final bool isMetric;
  final bool isHudMirrored;
  final VoidCallback? onToggleHud;
  final bool isLandscape;
  final VoidCallback? onToggleOrientation;

  const AuxiliaryGrid({
    super.key,
    required this.telemetry,
    required this.theme,
    required this.isMetric,
    this.isHudMirrored = false,
    this.onToggleHud,
    this.isLandscape = false,
    this.onToggleOrientation,
  });

  @override
  Widget build(BuildContext context) {
    final String tripDist;
    final String tripDistUnit;
    if (theme.distanceUnit == 'm') {
      tripDist = (telemetry.tripDistanceKm * 1000).toStringAsFixed(0);
      tripDistUnit = 'M';
    } else {
      tripDist = isMetric
          ? telemetry.tripDistanceKm.toStringAsFixed(1)
          : telemetry.tripDistanceMiles.toStringAsFixed(1);
      tripDistUnit = isMetric ? 'KM' : 'MI';
    }

    final avgSpeed = isMetric
        ? telemetry.averageSpeedKmh.toStringAsFixed(0)
        : UnitConverter.kmhToMph(telemetry.averageSpeedKmh).toStringAsFixed(0);
    final avgSpeedUnit = isMetric ? 'KM/H' : 'MPH';

    final movingTime = UnitConverter.formatMovingTime(
      telemetry.movingTimeSeconds,
    );
    final heading =
        '${telemetry.cardinalDirection} ${telemetry.headingDegrees.toStringAsFixed(0)}°';

    return Column(
      children: [
        // Top Quick Actions Bar (rendered in portrait; in landscape it is moved to TopStatusBar)
        if (!isLandscape)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HudQuickActions(
                  isHudMirrored: isHudMirrored,
                  onToggleHud: onToggleHud,
                  isLandscape: isLandscape,
                  onToggleOrientation: onToggleOrientation,
                  theme: theme,
                  buttonWidth: 44,
                  buttonHeight: 40,
                ),
              ],
            ),
          ),

        // 2x2 Telemetry Cards Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 2;
              final itemHeight = (constraints.maxHeight - 24) / 2;
              final ratio = (itemWidth / itemHeight.clamp(20.0, 500.0)).clamp(
                0.4,
                3.5,
              );

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: ratio,
                children: [
                  MetricCard(
                    label: 'Trip Distance',
                    value: tripDist,
                    unit: tripDistUnit,
                    icon: Icons.route_outlined,
                    theme: theme,
                  ),
                  MetricCard(
                    label: 'Moving Time',
                    value: movingTime,
                    icon: Icons.timer_outlined,
                    theme: theme,
                  ),
                  MetricCard(
                    label: 'Average Speed',
                    value: avgSpeed,
                    unit: avgSpeedUnit,
                    icon: Icons.speed_outlined,
                    theme: theme,
                  ),
                  CompassCard(
                    telemetry: telemetry,
                    theme: theme,
                    isMetric: isMetric,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
