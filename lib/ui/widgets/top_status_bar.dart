import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';

class TopStatusBar extends StatefulWidget {
  final bool isGpsLocked;
  final double gpsAccuracyMeters;
  final int batteryPercent;
  final HudTheme theme;

  const TopStatusBar({
    super.key,
    required this.isGpsLocked,
    required this.gpsAccuracyMeters,
    required this.batteryPercent,
    required this.theme,
  });

  @override
  State<TopStatusBar> createState() => _TopStatusBarState();
}

class _TopStatusBarState extends State<TopStatusBar> {
  late Timer _clockTimer;
  String _formattedTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now).toUpperCase();
    if (mounted) {
      setState(() => _formattedTime = timeStr);
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.theme.cardBackgroundColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: widget.theme.cardBorderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Clock
          Text(
            _formattedTime,
            style: widget.theme.getTelemetryTextStyle(
              fontSize: 14,
              color: widget.theme.cardValueColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          // GPS Status Pill
          _buildGpsPill(),

          // Battery Percentage
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.batteryPercent > 20
                    ? Icons.battery_charging_full_rounded
                    : Icons.battery_alert_rounded,
                color: widget.batteryPercent > 20
                    ? widget.theme.speedNormal
                    : widget.theme.speedCritical,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.batteryPercent}%',
                style: widget.theme.getTelemetryTextStyle(
                  fontSize: 13,
                  color: widget.theme.cardValueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pillColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pillColor,
              boxShadow: [
                BoxShadow(
                  color: pillColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: widget.theme.getTelemetryTextStyle(
              fontSize: 11,
              color: pillColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
