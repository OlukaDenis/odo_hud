import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../models/telemetry_state.dart';
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

    return Column(
      children: [
        // Top Quick Actions Bar (HUD flip & landscape toggle icons only)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Text(
                'LIVE TELEMETRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const Spacer(),
              _buildQuickActionButton(
                icon: Icons.flip_rounded,
                isActive: isHudMirrored,
                tooltip: 'Flip HUD',
                onTap: onToggleHud,
              ),
              const SizedBox(width: 8),
              _buildQuickActionButton(
                icon: isLandscape
                    ? Icons.stay_current_portrait_rounded
                    : Icons.stay_current_landscape_rounded,
                isActive: false,
                tooltip: isLandscape ? 'Portrait Mode' : 'Landscape Mode',
                onTap: onToggleOrientation,
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
              final ratio = (itemWidth / itemHeight.clamp(20.0, 500.0))
                  .clamp(0.4, 3.5);

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
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
                  MetricCard(
                    label: 'Heading',
                    value: heading,
                    icon: Icons.explore_outlined,
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(9),
        child: Ink(
          width: 38,
          height: 34,
          decoration: BoxDecoration(
            color: isActive
                ? theme.speedNormal.withValues(alpha: 0.9)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isActive
                  ? theme.speedNormal
                  : theme.cardBorderColor.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.black : theme.speedNormal,
            ),
          ),
        ),
      ),
    );
  }
}
