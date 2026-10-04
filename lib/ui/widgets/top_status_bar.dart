import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import 'hud_quick_actions.dart';

/// Sleek Top Toolbar replacing the former status bar.
/// Clock and battery have been removed to reduce clutter and focus purely on telemetry.
/// Features live GPS status, live trip recording badge, Trip History, and Settings.
class TopStatusBar extends StatefulWidget {
  final bool isGpsLocked;
  final double gpsAccuracyMeters;
  final HudTheme theme;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenTripHistory;
  final bool isRecordingTrip;
  final bool isTripPaused;
  final int recordedTripSeconds;
  final double recordedTripDistanceKm;
  final int batteryPercent; // Retained for backwards compatibility if needed
  final bool isLandscape;
  final bool isHudMirrored;
  final VoidCallback? onToggleHud;
  final VoidCallback? onToggleOrientation;

  const TopStatusBar({
    super.key,
    required this.isGpsLocked,
    required this.gpsAccuracyMeters,
    required this.theme,
    required this.onOpenSettings,
    required this.onOpenTripHistory,
    this.isRecordingTrip = false,
    this.isTripPaused = false,
    this.recordedTripSeconds = 0,
    this.recordedTripDistanceKm = 0.0,
    this.batteryPercent = 100,
    this.isLandscape = false,
    this.isHudMirrored = false,
    this.onToggleHud,
    this.onToggleOrientation,
  });

  @override
  State<TopStatusBar> createState() => _TopStatusBarState();
}

class _TopStatusBarState extends State<TopStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: widget.theme.cardBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.theme.cardBorderColor,
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: GPS Status Pill
          _buildGpsPill(),

          const SizedBox(width: 8),

          // Center: Active Trip Recording Badge (when recording)
          if (widget.isRecordingTrip)
            Expanded(
              child: _buildRecordingIndicator(),
            )
          else
            const Spacer(),

          // Right: Action Buttons (HUD Flip & Orientation when Landscape, Trip History & Settings)
          if (widget.isLandscape && widget.onToggleHud != null) ...[
            HudQuickActions(
              isHudMirrored: widget.isHudMirrored,
              onToggleHud: widget.onToggleHud,
              isLandscape: widget.isLandscape,
              onToggleOrientation: widget.onToggleOrientation,
              theme: widget.theme,
              buttonWidth: 44,
              buttonHeight: 44,
            ),
            const SizedBox(width: 8),
          ],
          _buildToolbarButton(
            icon: Icons.history_rounded,
            tooltip: 'Trip History',
            onTap: widget.onOpenTripHistory,
          ),
          const SizedBox(width: 8),
          _buildToolbarButton(
            icon: Icons.tune_rounded,
            tooltip: 'Settings',
            onTap: widget.onOpenSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildGpsPill() {
    final locked = widget.isGpsLocked;
    final pillColor = locked ? AppColors.gpsLocked : AppColors.gpsSearching;
    final accuracy = widget.gpsAccuracyMeters;

    // Calculate 1 to 4 active signal bars based on satellite accuracy
    final int activeBars;
    if (!locked) {
      activeBars = 1;
    } else if (accuracy <= 6) {
      activeBars = 4;
    } else if (accuracy <= 14) {
      activeBars = 3;
    } else if (accuracy <= 25) {
      activeBars = 2;
    } else {
      activeBars = 1;
    }

    final tooltipMsg = locked
        ? 'GPS Connected: ±${accuracy.toStringAsFixed(0)}m accuracy'
        : 'Acquiring GPS Signal...';

    return Tooltip(
      message: tooltipMsg,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: widget.theme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.theme.cardBorderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Network/Satellite signal bars
            _buildSignalBars(
              activeBars: activeBars,
              color: pillColor,
              isSearching: !locked,
            ),
            const SizedBox(width: 8),
            Text(
              'GPS',
              style: widget.theme.getTelemetryTextStyle(
                fontSize: 12,
                color: locked ? widget.theme.textColor : pillColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalBars({
    required int activeBars,
    required Color color,
    required bool isSearching,
  }) {
    // 4 stepped bars with heights: 4, 7, 10, 13
    const barHeights = [4.0, 7.0, 10.0, 13.0];
    const barWidth = 3.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final searchingAlpha = 0.3 + (_pulseAnimation.value * 0.7);

        return SizedBox(
          height: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (index) {
              final isActive = index < activeBars;
              final barColor = isSearching
                  ? color.withValues(alpha: searchingAlpha)
                  : (isActive ? color : color.withValues(alpha: 0.18));

              return Container(
                margin: EdgeInsets.only(right: index < 3 ? 2.5 : 0),
                width: barWidth,
                height: barHeights[index],
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: (isActive && !isSearching)
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 3,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRecordingIndicator() {
    final String distStr;
    if (widget.theme.distanceUnit == 'm') {
      distStr = '${(widget.recordedTripDistanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      distStr = widget.theme.isMetric
          ? '${widget.recordedTripDistanceKm.toStringAsFixed(1)} km'
          : '${UnitConverter.kmToMiles(widget.recordedTripDistanceKm).toStringAsFixed(1)} mi';
    }
    final timeStr = UnitConverter.formatMovingTime(widget.recordedTripSeconds);
    final isPaused = widget.isTripPaused;
    final color = isPaused ? const Color(0xFFFFB340) : Colors.redAccent;
    final statusText = isPaused ? 'PAUSED' : 'REC';

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(
                alpha: 0.4 + (_pulseAnimation.value * 0.4),
              ),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                        alpha: 0.5 + (_pulseAnimation.value * 0.5),
                      ),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$statusText  $timeStr • $distStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.theme.getTelemetryTextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.theme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.theme.cardBorderColor,
              width: 1.2,
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 21,
              color: widget.theme.textColor.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias for TopToolbar
typedef TopToolbar = TopStatusBar;
