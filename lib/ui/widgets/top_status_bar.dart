import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';

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
        color: widget.theme.cardBackgroundColor.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: widget.theme.cardBorderColor.withValues(alpha: 0.6),
            width: 1,
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

          // Right: Action Buttons (Trip History & Settings)
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
    final text = locked
        ? 'GPS Connected (±${widget.gpsAccuracyMeters.toStringAsFixed(0)}m)'
        : 'Finding GPS...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pillColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pillColor,
                  boxShadow: [
                    BoxShadow(
                      color: pillColor.withValues(
                        alpha: locked ? 0.3 + (_pulseAnimation.value * 0.4) : 0.6,
                      ),
                      blurRadius: 6,
                      spreadRadius: locked ? _pulseAnimation.value * 2 : 1,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: widget.theme.getTelemetryTextStyle(
              fontSize: 11,
              color: pillColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    final distStr = widget.theme.isMetric
        ? '${widget.recordedTripDistanceKm.toStringAsFixed(1)} km'
        : '${UnitConverter.kmToMiles(widget.recordedTripDistanceKm).toStringAsFixed(1)} mi';
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
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.theme.cardBorderColor.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 18,
              color: widget.theme.cardValueColor.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias for TopToolbar
typedef TopToolbar = TopStatusBar;
