import 'package:flutter/material.dart';
import '../../core/theme/hud_theme.dart';
import '../../models/telemetry_state.dart';
import 'auxiliary_grid.dart';
import 'speed_display.dart';

class DashboardPortraitLayout extends StatelessWidget {
  final TelemetryState telemetry;
  final HudTheme theme;
  final bool isMetric;
  final bool isLandscape;
  final VoidCallback onToggleHud;
  final VoidCallback onToggleOrientation;

  const DashboardPortraitLayout({
    super.key,
    required this.telemetry,
    required this.theme,
    required this.isMetric,
    required this.isLandscape,
    required this.onToggleHud,
    required this.onToggleOrientation,
  });

  @override
  Widget build(BuildContext context) {
    final currentSpeed = isMetric
        ? telemetry.displaySpeedKmh
        : telemetry.displaySpeedMph;

    return Column(
      children: [
        // Upper 60%: Dominant Speed Numeral
        Expanded(
          flex: 6,
          child: SpeedDisplay(
            currentSpeed: currentSpeed,
            speedKmh: telemetry.displaySpeedKmh,
            isMetric: isMetric,
            theme: theme,
          ),
        ),

        // Lower 40%: Compact 2x2 Auxiliary Grid with HUD & orientation actions
        Expanded(
          flex: 4,
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
      ],
    );
  }
}
