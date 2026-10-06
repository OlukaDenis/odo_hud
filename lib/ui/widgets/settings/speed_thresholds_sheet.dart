import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';

class SpeedThresholdsSheet extends ConsumerWidget {
  const SpeedThresholdsSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SpeedThresholdsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final liveConfig = ref.watch(themeConfigProvider);
    final notifier = ref.read(themeConfigProvider.notifier);
    final isMetric = liveConfig.isMetric;
    final unit = isMetric ? 'km/h' : 'mph';

    // Slider bounds adapt dynamically based on unit
    final double minWarn = isMetric ? 30.0 : 20.0;
    final double maxWarn = isMetric ? 180.0 : 110.0;
    final double minCrit = isMetric ? 50.0 : 35.0;
    final double maxCrit = isMetric ? 220.0 : 140.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: liveTheme.isDarkMode
            ? const Color(0xFF161618)
            : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: liveTheme.isDarkMode
              ? const Color(0xFF2C2C2E)
              : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: liveTheme.isDarkMode ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPEED ALERTS',
                style: liveTheme
                    .getTelemetryTextStyle(
                      fontSize: 16,
                      color: liveTheme.textColor,
                      fontWeight: FontWeight.bold,
                    )
                    .copyWith(letterSpacing: 0.8),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: liveTheme.subtitleColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            'Visual speed alerts change color dynamically at these boundaries',
            style: TextStyle(fontSize: 12, color: liveTheme.subtitleColor),
          ),
          const SizedBox(height: 18),

          // Quick Presets
          Row(
            children: [
              _buildPresetButton(
                label: 'City',
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.updateSpeedThresholds(
                    warningKmh: isMetric ? 50.0 : 30.0,
                    criticalKmh: isMetric ? 70.0 : 45.0,
                  );
                },
                theme: liveTheme,
              ),
              const SizedBox(width: 8),
              _buildPresetButton(
                label: 'Highway',
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.updateSpeedThresholds(
                    warningKmh: isMetric ? 100.0 : 65.0,
                    criticalKmh: isMetric ? 130.0 : 80.0,
                  );
                },
                theme: liveTheme,
              ),
              const SizedBox(width: 8),
              _buildPresetButton(
                label: 'Autobahn',
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.updateSpeedThresholds(
                    warningKmh: isMetric ? 140.0 : 85.0,
                    criticalKmh: isMetric ? 180.0 : 110.0,
                  );
                },
                theme: liveTheme,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Warning Threshold Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Warning Speed Threshold',
                style: TextStyle(
                  color: liveTheme.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${liveConfig.warningThresholdKmh.toInt()} $unit',
                style: TextStyle(
                  color: liveTheme.speedWarning,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: liveConfig.warningThresholdKmh.clamp(minWarn, maxWarn),
            min: minWarn,
            max: maxWarn,
            divisions: (maxWarn - minWarn).toInt(),
            activeColor: liveTheme.speedWarning,
            inactiveColor: liveTheme.isDarkMode
                ? Colors.white24
                : Colors.black12,
            onChanged: (val) =>
                notifier.updateSpeedThresholds(warningKmh: val.roundToDouble()),
          ),
          const SizedBox(height: 16),

          // 2. Critical Threshold Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Critical Speed Threshold',
                style: TextStyle(
                  color: liveTheme.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${liveConfig.criticalThresholdKmh.toInt()} $unit',
                style: TextStyle(
                  color: liveTheme.speedCritical,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: liveConfig.criticalThresholdKmh.clamp(minCrit, maxCrit),
            min: minCrit,
            max: maxCrit,
            divisions: (maxCrit - minCrit).toInt(),
            activeColor: liveTheme.speedCritical,
            inactiveColor: liveTheme.isDarkMode
                ? Colors.white24
                : Colors.black12,
            onChanged: (val) => notifier.updateSpeedThresholds(
              criticalKmh: val.roundToDouble(),
            ),
          ),
          const SizedBox(height: 16),

          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: liveTheme.speedNormal,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Save & Apply',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(color: theme.cardBorderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: theme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
