import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../core/utils/unit_converter.dart';
import '../../data/database/isar_service.dart';
import '../../data/models/trip_record.dart';
import '../../providers/theme_provider.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final TripRecord trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  late TripRecord _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  void _editTitle() {
    final controller = TextEditingController(text: _trip.title);
    final theme = ref.read(hudThemeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            theme.isDarkMode ? const Color(0xFF181818) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.cardBorderColor),
        ),
        title: Text(
          'Rename Ride',
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: theme.textColor),
          decoration: InputDecoration(
            hintText: 'e.g. Work Commute, Sunset Spin...',
            hintStyle: TextStyle(color: theme.subtitleColor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.cardBorderColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.speedNormal),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.subtitleColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.speedNormal,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                _trip.title = newTitle;
                await IsarService.instance.saveTrip(_trip);
                if (mounted) setState(() {});
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final theme = ref.read(hudThemeProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            theme.isDarkMode ? const Color(0xFF181818) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded,
                color: AppColors.criticalRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Ride?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Permanently remove "${_trip.title}" from your history? This action cannot be reversed.',
          style: TextStyle(color: theme.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: theme.subtitleColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await IsarService.instance.deleteTrip(_trip.id);
              HapticFeedback.heavyImpact();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareSummary(bool isMetric) {
    final dist = isMetric
        ? '${_trip.distanceKm.toStringAsFixed(2)} km'
        : '${UnitConverter.kmToMiles(_trip.distanceKm).toStringAsFixed(2)} mi';
    final movingTime = UnitConverter.formatMovingTime(
        _trip.movingDurationSeconds > 0
            ? _trip.movingDurationSeconds
            : _trip.durationSeconds);
    final avgSpd = isMetric
        ? '${_trip.avgSpeedKmh.toStringAsFixed(1)} km/h'
        : '${UnitConverter.kmhToMph(_trip.avgSpeedKmh).toStringAsFixed(1)} mph';
    final maxSpd = isMetric
        ? '${_trip.topSpeedKmh.toStringAsFixed(1)} km/h'
        : '${UnitConverter.kmhToMph(_trip.topSpeedKmh).toStringAsFixed(1)} mph';

    final text = '🏍️ ${_trip.title}\n'
        '📍 Distance: $dist\n'
        '⏱️ Moving Time: $movingTime\n'
        '⚡ Avg Speed: $avgSpd (Peak: $maxSpd)\n'
        'Tracked with OdoHUD';

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Color(0xFF00FF66), size: 18),
            SizedBox(width: 8),
            Text(
              'Ride summary copied to clipboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hudThemeProvider);
    final isMetric = theme.isMetric;

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(_trip.startTime);
    final startTimeStr = DateFormat('h:mm a').format(_trip.startTime);
    final endTimeStr = _trip.endTime != null
        ? DateFormat('h:mm a').format(_trip.endTime!)
        : 'In progress';

    final dist = isMetric
        ? _trip.distanceKm
        : UnitConverter.kmToMiles(_trip.distanceKm);
    final distUnit = isMetric ? 'km' : 'mi';

    final avgSpeed = isMetric
        ? _trip.avgSpeedKmh
        : UnitConverter.kmhToMph(_trip.avgSpeedKmh);
    final maxSpeed = isMetric
        ? _trip.topSpeedKmh
        : UnitConverter.kmhToMph(_trip.topSpeedKmh);
    final speedUnit = isMetric ? 'km/h' : 'mph';

    final totalElapsed = _trip.durationSeconds;
    final movingSec = _trip.movingDurationSeconds > 0
        ? _trip.movingDurationSeconds
        : _trip.durationSeconds;
    final pauseSec = _trip.pauseDurationSeconds > 0
        ? _trip.pauseDurationSeconds
        : (totalElapsed > movingSec ? totalElapsed - movingSec : 0);

    final events = _trip.events;

    return Scaffold(
      backgroundColor: theme.isDarkMode ? Colors.black : const Color(0xFFF6F6F9),
      appBar: AppBar(
        backgroundColor:
            theme.isDarkMode ? Colors.black : const Color(0xFFF6F6F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ride Details',
          style: theme.getTelemetryTextStyle(
            fontSize: 18,
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share ride',
            icon: Icon(Icons.share_outlined, color: theme.textColor, size: 21),
            onPressed: () => _shareSummary(isMetric),
          ),
          IconButton(
            tooltip: 'Delete ride',
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.criticalRed, size: 22),
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Hero Ride Title & Time Header
          _buildHeroHeader(dateStr, startTimeStr, endTimeStr, theme),
          const SizedBox(height: 16),

          // 2. Primary 4-Stat Metric Grid
          _buildPrimaryStatsGrid(
            dist: dist,
            distUnit: distUnit,
            movingSec: movingSec,
            avgSpeed: avgSpeed,
            maxSpeed: maxSpeed,
            speedUnit: speedUnit,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // 3. Time Balance: Moving vs. Stopped / Rest
          _buildTimeAnalysisCard(
            movingSec: movingSec,
            pauseSec: pauseSec,
            totalElapsed: totalElapsed,
            theme: theme,
          ),
          const SizedBox(height: 20),

          // 4. Milestone Timeline (Start, Pauses, Resumes, Finish)
          _buildJourneyTimeline(events, isMetric, distUnit, theme),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(String dateStr, String startTimeStr,
      String endTimeStr, HudTheme theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _trip.title.isEmpty ? 'Recorded Ride' : _trip.title,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 22,
                    color: theme.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Rename',
                icon: Icon(Icons.edit_outlined,
                    size: 19, color: theme.subtitleColor),
                onPressed: _editTitle,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: theme.subtitleColor),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 14, color: theme.speedNormal),
              const SizedBox(width: 6),
              Text(
                '$startTimeStr → $endTimeStr',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatsGrid({
    required double dist,
    required String distUnit,
    required int movingSec,
    required double avgSpeed,
    required double maxSpeed,
    required String speedUnit,
    required HudTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL DISTANCE',
                  value: dist.toStringAsFixed(2),
                  unit: distUnit.toUpperCase(),
                  icon: Icons.route_rounded,
                  highlight: true,
                  theme: theme,
                ),
              ),
              Container(width: 1, height: 44, color: theme.cardBorderColor),
              Expanded(
                child: _buildMetricTile(
                  label: 'MOVING TIME',
                  value: UnitConverter.formatMovingTime(movingSec),
                  unit: '',
                  icon: Icons.timer_outlined,
                  theme: theme,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: theme.cardBorderColor, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'AVERAGE SPEED',
                  value: avgSpeed.toStringAsFixed(1),
                  unit: speedUnit.toUpperCase(),
                  icon: Icons.speed_rounded,
                  theme: theme,
                ),
              ),
              Container(width: 1, height: 44, color: theme.cardBorderColor),
              Expanded(
                child: _buildMetricTile(
                  label: 'PEAK SPEED',
                  value: maxSpeed.toStringAsFixed(1),
                  unit: speedUnit.toUpperCase(),
                  icon: Icons.bolt_rounded,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    bool highlight = false,
    required HudTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.subtitleColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.getTelemetryTextStyle(
                  fontSize: 10,
                  color: theme.subtitleColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
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
                  fontSize: 22,
                  color: highlight ? theme.speedNormal : theme.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: theme.getTelemetryTextStyle(
                    fontSize: 11,
                    color: highlight ? theme.speedNormal : theme.subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisCard({
    required int movingSec,
    required int pauseSec,
    required int totalElapsed,
    required HudTheme theme,
  }) {
    final effectiveTotal =
        (movingSec + pauseSec) > 0 ? (movingSec + pauseSec) : 1;
    final movingRatio = (movingSec / effectiveTotal).clamp(0.0, 1.0);
    final pauseRatio = (pauseSec / effectiveTotal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RIDE TEMPO & REST TIME',
                style: theme.getTelemetryTextStyle(
                  fontSize: 11,
                  color: theme.subtitleColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              Text(
                'Total: ${UnitConverter.formatMovingTime(totalElapsed > 0 ? totalElapsed : effectiveTotal)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Segment Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (movingRatio * 100).toInt().clamp(1, 100),
                    child: Container(color: theme.speedNormal),
                  ),
                  if (pauseSec > 0)
                    Flexible(
                      flex: (pauseRatio * 100).toInt().clamp(1, 100),
                      child: Container(color: const Color(0xFFFFB340)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.speedNormal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'In Motion: ${UnitConverter.formatMovingTime(movingSec)} (${(movingRatio * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB340),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stopped / Idle: ${UnitConverter.formatMovingTime(pauseSec)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyTimeline(
      List<TripEvent> events, bool isMetric, String distUnit, HudTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded,
                  size: 16, color: theme.speedNormal),
              const SizedBox(width: 8),
              Text(
                'JOURNEY TIMELINE & EVENTS',
                style: theme.getTelemetryTextStyle(
                  fontSize: 11,
                  color: theme.subtitleColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (events.isEmpty)
            _buildFallbackTimeline(isMetric, distUnit, theme)
          else
            ...List.generate(events.length, (index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              return _buildTimelineItem(
                event: event,
                isLast: isLast,
                isMetric: isMetric,
                distUnit: distUnit,
                theme: theme,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required TripEvent event,
    required bool isLast,
    required bool isMetric,
    required String distUnit,
    required HudTheme theme,
  }) {
    IconData icon;
    Color iconColor;
    String title;
    String subtitle;

    final timeStr = DateFormat('h:mm:ss a').format(event.timestamp);
    final eventDist = isMetric
        ? event.distanceKm
        : UnitConverter.kmToMiles(event.distanceKm);
    final distStr = '${eventDist.toStringAsFixed(2)} $distUnit';

    switch (event.type) {
      case 'start':
        icon = Icons.play_arrow_rounded;
        iconColor = theme.speedNormal;
        title = 'Ride Started';
        subtitle = 'Departed at 0.00 $distUnit';
        break;
      case 'pause':
        icon = Icons.pause_rounded;
        iconColor = const Color(0xFFFFB340);
        title = 'Ride Paused / Rest Stop';
        subtitle = 'Halted at $distStr';
        break;
      case 'resume':
        icon = Icons.play_arrow_rounded;
        iconColor = const Color(0xFF34D399);
        title = 'Ride Resumed';
        subtitle = 'Continued journey at $distStr';
        break;
      case 'stop':
        icon = Icons.flag_rounded;
        iconColor = AppColors.criticalRed;
        title = 'Ride Finished & Saved';
        subtitle = 'Completed at $distStr';
        break;
      default:
        icon = Icons.circle;
        iconColor = theme.subtitleColor;
        title = event.type;
        subtitle = distStr;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(icon, size: 13, color: iconColor),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.cardBorderColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackTimeline(
      bool isMetric, String distUnit, HudTheme theme) {
    final startTimeStr = DateFormat('h:mm:ss a').format(_trip.startTime);
    final endTimeStr = _trip.endTime != null
        ? DateFormat('h:mm:ss a').format(_trip.endTime!)
        : 'Active';
    final totalDist = isMetric
        ? _trip.distanceKm
        : UnitConverter.kmToMiles(_trip.distanceKm);

    return Column(
      children: [
        _buildStaticTimelinePoint(
          icon: Icons.play_arrow_rounded,
          iconColor: theme.speedNormal,
          title: 'Ride Started',
          subtitle: 'Departed at 0.00 $distUnit',
          timeStr: startTimeStr,
          isLast: false,
          theme: theme,
        ),
        _buildStaticTimelinePoint(
          icon: Icons.flag_rounded,
          iconColor: AppColors.criticalRed,
          title: 'Ride Finished',
          subtitle: 'Completed at ${totalDist.toStringAsFixed(2)} $distUnit',
          timeStr: endTimeStr,
          isLast: true,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStaticTimelinePoint({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String timeStr,
    required bool isLast,
    required HudTheme theme,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(icon, size: 13, color: iconColor),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.cardBorderColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
