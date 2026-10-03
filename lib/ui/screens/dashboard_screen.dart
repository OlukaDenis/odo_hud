import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/theme/hud_theme.dart';
import '../../models/telemetry_state.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/action_bar.dart';
import '../widgets/auxiliary_grid.dart';
import '../widgets/speed_display.dart';
import '../widgets/top_status_bar.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Keep screen awake during active rides
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryProvider);
    final theme = ref.watch(hudThemeProvider);
    final isMetric = theme.isMetric;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Transform(
          alignment: Alignment.center,
          transform: telemetry.isHudMirrored
              ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
              : Matrix4.identity(),
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              return Column(
                children: [
                  // Top Status Bar (Clock, GPS status, Battery)
                  TopStatusBar(
                    isGpsLocked: telemetry.isGpsLocked,
                    gpsAccuracyMeters: telemetry.gpsAccuracyMeters,
                    batteryPercent: telemetry.batteryPercent,
                    theme: theme,
                  ),

                  // Responsive Body
                  Expanded(
                    child: isLandscape
                        ? _buildLandscapeLayout(telemetry, theme, isMetric)
                        : _buildPortraitLayout(telemetry, theme, isMetric),
                  ),

                  // Bottom Action Bar (Mirror, Settings, Guarded Reset)
                  ActionBar(
                    isHudMirrored: telemetry.isHudMirrored,
                    onToggleHud: () =>
                        ref.read(telemetryProvider.notifier).toggleHudMirror(),
                    onOpenSettings: _openSettings,
                    onResetTrip: () =>
                        ref.read(telemetryProvider.notifier).resetTrip(),
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    TelemetryState telemetry,
    HudTheme theme,
    bool isMetric,
  ) {
    final currentSpeed =
        isMetric ? telemetry.currentSpeedKmh : telemetry.currentSpeedMph;

    return Row(
      children: [
        // Left 50%: Speed Numeral
        Expanded(
          flex: 1,
          child: SpeedDisplay(
            currentSpeed: currentSpeed,
            speedKmh: telemetry.currentSpeedKmh,
            isMetric: isMetric,
            theme: theme,
          ),
        ),

        // Right 50%: 2x2 Auxiliary Grid
        Expanded(
          flex: 1,
          child: AuxiliaryGrid(
            telemetry: telemetry,
            theme: theme,
            isMetric: isMetric,
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    TelemetryState telemetry,
    HudTheme theme,
    bool isMetric,
  ) {
    final currentSpeed =
        isMetric ? telemetry.currentSpeedKmh : telemetry.currentSpeedMph;

    return Column(
      children: [
        // Upper 48%: Speed Numeral
        Expanded(
          flex: 5,
          child: SpeedDisplay(
            currentSpeed: currentSpeed,
            speedKmh: telemetry.currentSpeedKmh,
            isMetric: isMetric,
            theme: theme,
          ),
        ),

        // Lower 52%: 2x2 Auxiliary Grid
        Expanded(
          flex: 5,
          child: AuxiliaryGrid(
            telemetry: telemetry,
            theme: theme,
            isMetric: isMetric,
          ),
        ),
      ],
    );
  }
}
