import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../models/telemetry_state.dart';
import '../../../providers/telemetry_provider.dart';
import '../../../providers/theme_provider.dart';
import 'compass_dial.dart';

class CompassBottomSheet extends ConsumerWidget {
  const CompassBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CompassBottomSheet(),
    );
  }

  void _copyCoordinates(BuildContext context, double lat, double lon) {
    final coordText = UnitConverter.formatCoordinates(lat, lon);
    Clipboard.setData(ClipboardData(text: coordText));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Coordinates copied: $coordText',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetry = ref.watch(telemetryProvider);
    final theme = ref.watch(hudThemeProvider);
    final isMetric = theme.isMetric;

    final headingDeg = telemetry.headingDegrees;
    final cardinal = telemetry.cardinalDirection;
    final cardinalFullName = UnitConverter.degreesToCardinalFullName(headingDeg);
    final altitudeStr = UnitConverter.formatAltitude(telemetry.altitudeMeters, isMetric);
    final coordsStr = UnitConverter.formatCoordinates(telemetry.latitude, telemetry.longitude);

    final isMoving = telemetry.currentSpeedKmh > 1.5;
    final sensorSource = isMoving ? 'GPS Course' : 'Magnetic Sensor';

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? const Color(0xFF14161A)
              : const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.cardBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: Color(0xFFFF3B30),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compass & Navigation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        Text(
                          'Live Heading & Elevation Telemetry',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.subtitleColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Dial Section
              Center(
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: CompassDial(
                    headingDegrees: headingDeg,
                    size: 210,
                    isMini: false,
                    theme: theme,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Digital Readout Banner
              Column(
                children: [
                  Text(
                    '${headingDeg.toStringAsFixed(0)}°',
                    style: theme.getSpeedTextStyle(
                      fontSize: 40,
                      color: theme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.cardBorderColor),
                    ),
                    child: Text(
                      '$cardinal · $cardinalFullName',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF3B30),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Telemetry Grid (Altitude & GPS Accuracy)
              Row(
                children: [
                  // Altitude / Elevation Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.cardBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.terrain_rounded,
                                size: 16,
                                color: theme.speedNormal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ALTITUDE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: theme.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            altitudeStr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Above sea level',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // GPS Accuracy Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.cardBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                telemetry.isGpsLocked
                                    ? Icons.gps_fixed_rounded
                                    : Icons.gps_not_fixed_rounded,
                                size: 16,
                                color: telemetry.isGpsLocked
                                    ? AppColors.gpsLocked
                                    : AppColors.criticalRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'GPS ACCURACY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: theme.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '± ${telemetry.gpsAccuracyMeters.toStringAsFixed(1)} m',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: theme.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            telemetry.isGpsLocked ? 'Signal Locked' : 'Searching...',
                            style: TextStyle(
                              fontSize: 10,
                              color: telemetry.isGpsLocked
                                  ? AppColors.gpsLocked
                                  : AppColors.criticalRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Coordinates Banner with Copy Action
              Material(
                color: theme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _copyCoordinates(
                    context,
                    telemetry.latitude,
                    telemetry.longitude,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: theme.subtitleColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COORDINATES',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: theme.subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coordsStr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.isDarkMode ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: theme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Source Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    size: 13,
                    color: theme.subtitleColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Active source: $sensorSource',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
