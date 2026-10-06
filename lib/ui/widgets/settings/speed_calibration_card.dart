import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/speed_calibration_provider.dart';
import '../../../providers/theme_provider.dart';
import 'speed_calibration_sheet.dart';

class SpeedCalibrationCard extends ConsumerWidget {
  const SpeedCalibrationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final calibration = ref.watch(speedCalibrationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SPEEDOMETER CALIBRATION', theme),
        Material(
          color: theme.cardBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.cardBorderColor),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.tune_rounded, color: theme.textColor, size: 20),
            ),
            title: Text(
              'Speed Calibration & Offset',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              calibration.isEnabled
                  ? 'Offset: ${calibration.summaryText} (Tire / Dash Match)'
                  : 'Disabled • Using True GPS Ground Speed',
              style: TextStyle(color: theme.subtitleColor, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: calibration.isEnabled
                        ? theme.primaryColor.withValues(alpha: 0.15)
                        : (theme.isDarkMode ? Colors.white10 : Colors.black12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    calibration.isEnabled ? calibration.summaryText : 'OFF',
                    style: TextStyle(
                      color: calibration.isEnabled
                          ? theme.primaryColor
                          : theme.subtitleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.subtitleColor,
                  size: 20,
                ),
              ],
            ),
            onTap: () => SpeedCalibrationSheet.show(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, HudTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: theme
            .getTelemetryTextStyle(
              fontSize: 13.0,
              color: theme.subtitleColor,
              fontWeight: FontWeight.normal,
            )
            .copyWith(letterSpacing: 0.2),
      ),
    );
  }
}
