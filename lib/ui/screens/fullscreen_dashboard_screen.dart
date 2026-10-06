import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/speed_display.dart';

/// Fullscreen minimal HUD dashboard.
/// Stripped of the top status bar, showing only the dominant speed numeral,
/// minimal counts of distance and minutes, and an action to quit fullscreen.
class FullscreenDashboardScreen extends ConsumerStatefulWidget {
  const FullscreenDashboardScreen({super.key});

  @override
  ConsumerState<FullscreenDashboardScreen> createState() =>
      _FullscreenDashboardScreenState();
}

class _FullscreenDashboardScreenState
    extends ConsumerState<FullscreenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure sticky immersive mode is enabled
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    // Keep immersive mode for dashboard when popping back
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.dispose();
  }

  void _quitFullscreen() {
    HapticFeedback.selectionClick();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryProvider);
    final theme = ref.watch(hudThemeProvider);
    final isMetric = theme.isMetric;

    final currentSpeed =
        isMetric ? telemetry.currentSpeedKmh : telemetry.currentSpeedMph;

    // Minimal distance string
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

    // Minimal moving minutes & time string
    final int minutes = telemetry.movingTimeSeconds ~/ 60;
    final String timeFormatted =
        UnitConverter.formatMovingTime(telemetry.movingTimeSeconds);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Transform(
          alignment: Alignment.center,
          transform: telemetry.isHudMirrored
              ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
              : Matrix4.identity(),
          child: Stack(
            children: [
              // Main Speed & Minimal Counts Layout
              OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;

                  if (isLandscape) {
                    return Row(
                      children: [
                        // Left 65%: Large Speed
                        Expanded(
                          flex: 13,
                          child: Center(
                            child: SpeedDisplay(
                              currentSpeed: currentSpeed,
                              speedKmh: telemetry.currentSpeedKmh,
                              isMetric: isMetric,
                              theme: theme,
                            ),
                          ),
                        ),

                        // Right 35%: Minimal Distance & Minutes Counts
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMinimalCard(
                                  label: 'DISTANCE',
                                  value: tripDist,
                                  unit: tripDistUnit,
                                  icon: Icons.straighten_rounded,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                _buildMinimalCard(
                                  label: 'MINUTES',
                                  value: '$minutes',
                                  unit: 'MIN ($timeFormatted)',
                                  icon: Icons.timer_outlined,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Portrait Layout
                  return Column(
                    children: [
                      // Upper 70%: Large Dominant Speed Numeral
                      Expanded(
                        flex: 7,
                        child: Center(
                          child: SpeedDisplay(
                            currentSpeed: currentSpeed,
                            speedKmh: telemetry.currentSpeedKmh,
                            isMetric: isMetric,
                            theme: theme,
                          ),
                        ),
                      ),

                      // Lower 30%: Minimal Distance & Minutes Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMinimalCard(
                                label: 'DISTANCE',
                                value: tripDist,
                                unit: tripDistUnit,
                                icon: Icons.straighten_rounded,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMinimalCard(
                                label: 'MINUTES',
                                value: '$minutes',
                                unit: 'MIN ($timeFormatted)',
                                icon: Icons.timer_outlined,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Top-Right Floating Controls (Flip HUD & Quit Fullscreen)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // HUD Flip Toggle
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(telemetryProvider.notifier)
                              .toggleHudMirror();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: telemetry.isHudMirrored
                                ? theme.speedNormal.withValues(alpha: 0.9)
                                : theme.cardBackgroundColor
                                    .withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.cardBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.flip_rounded,
                            size: 20,
                            color: telemetry.isHudMirrored
                                ? Colors.black
                                : theme.subtitleColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quit Fullscreen Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _quitFullscreen,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.cardBackgroundColor
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.cardBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fullscreen_exit_rounded,
                                size: 20,
                                color: theme.speedNormal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'EXIT',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required HudTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.cardBorderColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.subtitleColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.subtitleColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.getTelemetryTextStyle(
                  fontSize: 26,
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.subtitleColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
