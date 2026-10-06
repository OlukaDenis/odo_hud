import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/database/isar_service.dart';
import '../../data/models/trip_record.dart';
import '../../providers/theme_provider.dart';

class TripHistoryScreen extends ConsumerStatefulWidget {
  final Stream<List<TripRecord>>? tripsStream;

  const TripHistoryScreen({super.key, this.tripsStream});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> {
  final IsarService _isarService = IsarService.instance;

  Stream<List<TripRecord>> get _effectiveStream =>
      widget.tripsStream ?? _isarService.watchAllTrips();

  void _confirmDeleteTrip(BuildContext context, TripRecord trip) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.criticalRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Ride?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${trip.title}" from your history? This cannot be undone.',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final messenger = ScaffoldMessenger.of(context);
              await _isarService.deleteTrip(trip.id);
              HapticFeedback.heavyImpact();
              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF222222),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: const Text(
                    'Ride deleted',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        title: const Text(
          'Clear All Rides?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will permanently delete all recorded trip telemetry and reset your history.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _isarService.clearAllTrips();
              HapticFeedback.heavyImpact();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hudThemeProvider);
    final isMetric = theme.isMetric;

    return StreamBuilder<List<TripRecord>>(
      stream: _effectiveStream,
      builder: (context, snapshot) {
        final trips = snapshot.data ?? [];
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip History',
                  style: theme.getTelemetryTextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recorded ride telemetry & insights',
                  style: theme.getTelemetryTextStyle(
                    fontSize: 12.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              if (trips.isNotEmpty)
                IconButton(
                  tooltip: 'Clear All Rides',
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.white70, size: 22),
                  onPressed: () => _confirmClearAll(context),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.cyanAccent),
                )
              : trips.isEmpty
                  ? _buildEmptyState(context, theme)
                  : ListView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      children: [
                        // Summary Banner
                        _buildSummaryHeader(trips, isMetric, theme),
                        const SizedBox(height: 20),

                        // Section Label
                        Text(
                          'PAST RIDES (${trips.length})',
                          style: theme.getTelemetryTextStyle(
                            fontSize: 12.0,
                            color: Colors.white54,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Ride Cards
                        ...trips.map((trip) => _buildTripCard(trip, isMetric, theme)),
                        const SizedBox(height: 32),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildSummaryHeader(
      List<TripRecord> trips, bool isMetric, HudTheme theme) {
    double totalKm = 0.0;
    int totalMovingSeconds = 0;
    int totalDurationSeconds = 0;
    double maxSpeed = 0.0;

    for (final trip in trips) {
      totalKm += trip.distanceKm;
      totalDurationSeconds += trip.durationSeconds;
      totalMovingSeconds += trip.movingDurationSeconds > 0
          ? trip.movingDurationSeconds
          : trip.durationSeconds;
      if (trip.topSpeedKmh > maxSpeed) {
        maxSpeed = trip.topSpeedKmh;
      }
    }

    final displayDistance =
        isMetric ? totalKm : UnitConverter.kmToMiles(totalKm);
    final distUnit = isMetric ? 'KM' : 'MI';

    final displayTopSpeed =
        isMetric ? maxSpeed : UnitConverter.kmhToMph(maxSpeed);
    final speedUnit = isMetric ? 'KM/H' : 'MPH';

    final avgDistPerRide =
        trips.isNotEmpty ? displayDistance / trips.length : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Pill & Badge
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.cyanAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanAccent.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIFETIME TELEMETRY',
                    style: theme.getTelemetryTextStyle(
                      fontSize: 11.0,
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2E2E)),
                ),
                child: Text(
                  '${trips.length} ${trips.length == 1 ? 'ride' : 'rides'}',
                  style: theme.getTelemetryTextStyle(
                    fontSize: 11.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Row 1: Total Distance & Time in Motion
        Row(
          children: [
            Expanded(
              child: _buildSleekStatCard(
                label: 'TOTAL DISTANCE',
                value: displayDistance.toStringAsFixed(1),
                unit: distUnit,
                subtitle: '${trips.length} total logged',
                icon: Icons.route_rounded,
                accentColor: AppColors.cyanAccent,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSleekStatCard(
                label: 'TIME IN SADDLE',
                value: UnitConverter.formatMovingTime(totalMovingSeconds > 0
                    ? totalMovingSeconds
                    : totalDurationSeconds),
                unit: '',
                subtitle: 'Active riding time',
                icon: Icons.timer_outlined,
                accentColor: theme.speedNormal,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Record Peak & Avg Per Ride
        Row(
          children: [
            Expanded(
              child: _buildSleekStatCard(
                label: 'RECORD PEAK',
                value: displayTopSpeed.toStringAsFixed(0),
                unit: speedUnit,
                subtitle: 'All-time maximum',
                icon: Icons.bolt_rounded,
                accentColor: const Color(0xFFFFB800),
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSleekStatCard(
                label: 'AVG PER RIDE',
                value: avgDistPerRide.toStringAsFixed(1),
                unit: distUnit,
                subtitle: 'Average distance',
                icon: Icons.explore_outlined,
                accentColor: const Color(0xFF818CF8),
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleekStatCard({
    required String label,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required HudTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF242424),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge + label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 10.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Value + Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.getTelemetryTextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 10.0,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle / context
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.0,
              color: Colors.white38,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripRecord trip, bool isMetric, HudTheme theme) {
    final dist = isMetric ? trip.distanceKm : UnitConverter.kmToMiles(trip.distanceKm);
    final distUnit = isMetric ? 'km' : 'mi';

    final avgSpeed = isMetric ? trip.avgSpeedKmh : UnitConverter.kmhToMph(trip.avgSpeedKmh);
    final maxSpeed = isMetric ? trip.topSpeedKmh : UnitConverter.kmhToMph(trip.topSpeedKmh);
    final speedUnit = isMetric ? 'km/h' : 'mph';

    final dateStr = DateFormat('EEE, MMM d, yyyy').format(trip.startTime);
    final timeStr = DateFormat('h:mm a').format(trip.startTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF242424),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/history/detail', extra: trip);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title & Date & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  trip.title.isEmpty ? 'Recorded Ride' : trip.title,
                                  style: theme.getTelemetryTextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Colors.white30,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateStr • $timeStr',
                            style: theme.getTelemetryTextStyle(
                              fontSize: 12.0,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 20, color: Colors.white38),
                      onPressed: () => _confirmDeleteTrip(context, trip),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0xFF222222), height: 1),
                const SizedBox(height: 14),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTripMetric(
                      label: 'DISTANCE',
                      value: dist.toStringAsFixed(1),
                      unit: distUnit,
                      theme: theme,
                      highlight: true,
                    ),
                    _buildTripMetric(
                      label: 'DURATION',
                      value: UnitConverter.formatMovingTime(
                          trip.movingDurationSeconds > 0
                              ? trip.movingDurationSeconds
                              : trip.durationSeconds),
                      unit: '',
                      theme: theme,
                    ),
                    _buildTripMetric(
                      label: 'AVG SPEED',
                      value: avgSpeed.toStringAsFixed(1),
                      unit: speedUnit,
                      theme: theme,
                    ),
                    _buildTripMetric(
                      label: 'MAX SPEED',
                      value: maxSpeed.toStringAsFixed(1),
                      unit: speedUnit,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripMetric({
    required String label,
    required String value,
    required String unit,
    required HudTheme theme,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.getTelemetryTextStyle(
            fontSize: 10.0,
            color: Colors.white38,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: theme.getTelemetryTextStyle(
                fontSize: 16.0,
                color: highlight ? theme.speedNormal : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: theme.getTelemetryTextStyle(
                  fontSize: 10.0,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, HudTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF262626), width: 1.5),
              ),
              child: const Icon(
                Icons.route_rounded,
                size: 38,
                color: AppColors.cyanAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recorded Rides Yet',
              style: theme.getTelemetryTextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Whenever you take off, tap "Start Trip" on the bottom dashboard toolbar. Your route distance, duration, and top speeds will automatically be saved here.',
              textAlign: TextAlign.center,
              style: theme.getTelemetryTextStyle(
                fontSize: 14.0,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFF333333)),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Dashboard'),
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
