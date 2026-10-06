import 'package:flutter/material.dart';
import '../../core/theme/hud_theme.dart';
import '../../models/telemetry_state.dart';
import 'auxiliary_grid.dart';
import 'speed_display.dart';

class DashboardLandscapeLayout extends StatelessWidget {
  final TelemetryState telemetry;
  final HudTheme theme;
  final bool isMetric;
  final bool isLandscape;
  final Widget actionBar;
  final VoidCallback onToggleHud;
  final VoidCallback onToggleOrientation;

  const DashboardLandscapeLayout({
    super.key,
    required this.telemetry,
    required this.theme,
    required this.isMetric,
    required this.isLandscape,
    required this.actionBar,
    required this.onToggleHud,
    required this.onToggleOrientation,
  });

  @override
  Widget build(BuildContext context) {
    final currentSpeed = isMetric
        ? telemetry.displaySpeedKmh
        : telemetry.displaySpeedMph;

    return Row(
      children: [
        // Left 55%: Full-height Speed Numeral (completely uninterrupted)
        Expanded(
          flex: 11,
          child: SpeedDisplay(
            currentSpeed: currentSpeed,
            speedKmh: telemetry.displaySpeedKmh,
            isMetric: isMetric,
            theme: theme,
          ),
        ),

        // Right 45%: 2x2 Auxiliary Grid + Action Bar (matching exact width of the grid)
        Expanded(
          flex: 9,
          child: Column(
            children: [
              Expanded(
                child: AuxiliaryGrid(
                  telemetry: telemetry,
                  theme: theme,
                  isMetric: isMetric,
                  isHudMirrored: telemetry.isHudMirrored,
                  onToggleHud: onToggleHud,
                  isLandscape: isLandscape,
                  onToggleOrientation: onToggleOrientation,
                ),
              ),
              actionBar,
            ],
          ),
        ),
      ],
    );
  }
}
