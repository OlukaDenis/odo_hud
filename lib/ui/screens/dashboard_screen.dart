import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/models/trip_record.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/action_bar.dart';
import '../widgets/dashboard_landscape_layout.dart';
import '../widgets/dashboard_portrait_layout.dart';
import '../widgets/top_status_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Enable immersive fullscreen mode (hide system status bar & nav bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Keep screen awake during active rides
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    // Restore normal system overlays and free device auto-orientation on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _openSettings() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await context.push('/settings');
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _openFullscreen() async {
    HapticFeedback.selectionClick();
    await context.push('/fullscreen-dashboard');
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _openTripHistory() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await context.push('/history');
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> _openTripDetail(TripRecord trip) async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await context.push('/history/detail', extra: trip);
    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _confirmResetTrip() {
    final telemetry = ref.read(telemetryProvider);
    final isRecording = telemetry.isRecordingTrip;
    final theme = ref.read(hudThemeProvider);

    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color(0xFF161616)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.cardBorderColor),
        ),
        title: Row(
          children: [
            Icon(
              isRecording ? Icons.warning_amber_rounded : Icons.refresh_rounded,
              color: isRecording ? AppColors.criticalRed : theme.speedNormal,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isRecording ? 'Discard Ride?' : 'Reset Trip Meters?',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isRecording
              ? 'This will cancel the active recording and reset all trip counters to 0. The current ride will not be saved.'
              : 'Reset active trip distance, moving time, and average speed to 0.0? Your overall lifetime odometer will be preserved.',
          style: TextStyle(
            color: theme.subtitleColor,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isRecording ? 'Keep Riding' : 'Cancel',
              style: TextStyle(color: theme.subtitleColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecording
                  ? AppColors.criticalRed
                  : theme.speedNormal,
              foregroundColor: isRecording ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              ref.read(telemetryProvider.notifier).resetTrip();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1E1E1E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF333333)),
                  ),
                  duration: const Duration(seconds: 2),
                  content: Text(
                    isRecording ? 'Ride discarded' : 'Trip meters reset to 0.0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
            child: Text(
              isRecording ? 'Discard & Reset' : 'Reset Trip',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleRecording() async {
    final telemetry = ref.read(telemetryProvider);
    final notifier = ref.read(telemetryProvider.notifier);

    if (telemetry.isRecordingTrip) {
      final trip = await notifier.stopTripRecording();
      if (trip != null && mounted) {
        _showTripFinishedSheet(trip);
      }
    } else {
      await notifier.startTripRecording();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFF333333)),
            ),
            duration: const Duration(seconds: 2),
            content: const Row(
              children: [
                Icon(
                  Icons.fiber_manual_record_rounded,
                  color: Colors.redAccent,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Trip recording active',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _showTripFinishedSheet(TripRecord trip) {
    final theme = ref.read(hudThemeProvider);
    final isMetric = theme.isMetric;

    final dist = isMetric
        ? '${trip.distanceKm.toStringAsFixed(2)} km'
        : '${UnitConverter.kmToMiles(trip.distanceKm).toStringAsFixed(2)} mi';
    final duration = UnitConverter.formatMovingTime(trip.durationSeconds);
    final avgSpeed = isMetric
        ? '${trip.avgSpeedKmh.toStringAsFixed(1)} km/h'
        : '${UnitConverter.kmhToMph(trip.avgSpeedKmh).toStringAsFixed(1)} mph';
    final topSpeed = isMetric
        ? '${trip.topSpeedKmh.toStringAsFixed(1)} km/h'
        : '${UnitConverter.kmhToMph(trip.topSpeedKmh).toStringAsFixed(1)} mph';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? const Color(0xFF141414)
              : const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.cardBorderColor, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.speedNormal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: theme.speedNormal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ride Saved!',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        trip.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xFF1B1B1B)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.cardBorderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModalStat(
                      'DISTANCE',
                      dist,
                      highlight: true,
                      theme: theme,
                    ),
                  ),
                  Expanded(
                    child: _buildModalStat('DURATION', duration, theme: theme),
                  ),
                  Expanded(
                    child: _buildModalStat('AVG SPEED', avgSpeed, theme: theme),
                  ),
                  Expanded(
                    child: _buildModalStat('MAX SPEED', topSpeed, theme: theme),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.subtitleColor,
                      side: BorderSide(color: theme.cardBorderColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.speedNormal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openTripDetail(trip);
                    },
                    child: const Text(
                      'View Ride Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStat(
    String label,
    String value, {
    bool highlight = false,
    required HudTheme theme,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: theme.subtitleColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: highlight ? theme.speedNormal : theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _toggleOrientation(bool isCurrentlyLandscape) {
    HapticFeedback.selectionClick();
    if (isCurrentlyLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
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

              final actionBar = ActionBar(
                isRecordingTrip: telemetry.isRecordingTrip,
                onToggleRecording: _handleToggleRecording,
                isTripPaused: telemetry.isTripPaused,
                onTogglePause: () => ref
                    .read(telemetryProvider.notifier)
                    .togglePauseTripRecording(),
                onResetTrip: _confirmResetTrip,
                theme: theme,
              );

              return Column(
                children: [
                  // Top Toolbar (Live GPS status, active trip pill, trip history & settings)
                  TopStatusBar(
                    isGpsLocked: telemetry.isGpsLocked,
                    gpsAccuracyMeters: telemetry.gpsAccuracyMeters,
                    theme: theme,
                    onOpenSettings: _openSettings,
                    onOpenTripHistory: _openTripHistory,
                    onOpenFullscreen: _openFullscreen,
                    isRecordingTrip: telemetry.isRecordingTrip,
                    isTripPaused: telemetry.isTripPaused,
                    recordedTripSeconds: telemetry.recordedTripSeconds,
                    recordedTripDistanceKm: telemetry.recordedTripDistanceKm,
                    isLandscape: isLandscape,
                    isHudMirrored: telemetry.isHudMirrored,
                    onToggleHud: () =>
                        ref.read(telemetryProvider.notifier).toggleHudMirror(),
                    onToggleOrientation: () => _toggleOrientation(isLandscape),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isLandscape
                        ? DashboardLandscapeLayout(
                            telemetry: telemetry,
                            theme: theme,
                            isMetric: isMetric,
                            isLandscape: isLandscape,
                            actionBar: actionBar,
                            onToggleHud: () => ref
                                .read(telemetryProvider.notifier)
                                .toggleHudMirror(),
                            onToggleOrientation: () =>
                                _toggleOrientation(isLandscape),
                          )
                        : DashboardPortraitLayout(
                            telemetry: telemetry,
                            theme: theme,
                            isMetric: isMetric,
                            isLandscape: isLandscape,
                            onToggleHud: () => ref
                                .read(telemetryProvider.notifier)
                                .toggleHudMirror(),
                            onToggleOrientation: () =>
                                _toggleOrientation(isLandscape),
                          ),
                  ),

                  // Bottom Action Bar (rendered at bottom in Portrait; nested under grid in Landscape)
                  if (!isLandscape) actionBar,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
