import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../models/speed_calibration_config.dart';
import '../../../providers/speed_calibration_provider.dart';
import '../../../providers/theme_provider.dart';

class SpeedCalibrationSheet extends ConsumerWidget {
  const SpeedCalibrationSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SpeedCalibrationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final calibration = ref.watch(speedCalibrationProvider);
    final notifier = ref.read(speedCalibrationProvider.notifier);
    final isMetric = liveTheme.isMetric;
    final unit = isMetric ? 'km/h' : 'mph';

    // Simulated benchmark speeds to demonstrate calibration
    final double bench100 = isMetric ? 100.0 : 60.0;
    final double bench50 = isMetric ? 50.0 : 30.0;
    final double displayBench100 = calibration.isEnabled
        ? calibration.apply(bench100)
        : bench100;
    final double displayBench50 = calibration.isEnabled
        ? calibration.apply(bench50)
        : bench50;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
      child: SingleChildScrollView(
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

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SPEED CALIBRATION OFFSET',
                    style: liveTheme
                        .getTelemetryTextStyle(
                          fontSize: 16,
                          color: liveTheme.textColor,
                          fontWeight: FontWeight.bold,
                        )
                        .copyWith(letterSpacing: 0.8),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: liveTheme.subtitleColor,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Text(
              'Calibrate HUD readout to mirror your car dashboard (UNECE Reg 39) or aftermarket tire sizes.',
              style: TextStyle(fontSize: 12, color: liveTheme.subtitleColor),
            ),
            const SizedBox(height: 16),

            // Master Enable Toggle Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: calibration.isEnabled
                    ? liveTheme.primaryColor.withValues(alpha: 0.12)
                    : (liveTheme.isDarkMode
                          ? const Color(0xFF202024)
                          : const Color(0xFFF2F2F7)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: calibration.isEnabled
                      ? liveTheme.primaryColor.withValues(alpha: 0.5)
                      : (liveTheme.isDarkMode
                            ? const Color(0xFF2E2E32)
                            : const Color(0xFFE5E5EA)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: calibration.isEnabled
                        ? liveTheme.primaryColor
                        : liveTheme.subtitleColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Speed Calibration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: liveTheme.textColor,
                          ),
                        ),
                        Text(
                          calibration.isEnabled
                              ? 'Active: ${calibration.summaryText}'
                              : 'Disabled (Pure GPS ground speed)',
                          style: TextStyle(
                            fontSize: 11,
                            color: calibration.isEnabled
                                ? liveTheme.primaryColor
                                : liveTheme.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: calibration.isEnabled,
                    activeThumbColor: liveTheme.primaryColor,
                    activeTrackColor: liveTheme.primaryColor.withValues(alpha: 0.5),
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.setEnabled(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Presets Header & Chips
            Text(
              'AUTOMOTIVE CALIBRATION PRESETS',
              style: liveTheme
                  .getTelemetryTextStyle(
                    fontSize: 11,
                    color: liveTheme.textColor,
                    fontWeight: FontWeight.bold,
                  )
                  .copyWith(letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip(
                  label: 'True GPS (0%)',
                  isSelected:
                      !calibration.isEnabled ||
                      (calibration.percentageOffset == 0.0 &&
                          calibration.fixedOffsetKmh == 0.0),
                  liveTheme: liveTheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.resetToGpsTrue();
                  },
                ),
                _buildPresetChip(
                  label: 'Factory +5%',
                  isSelected:
                      calibration.isEnabled &&
                      calibration.percentageOffset == 5.0 &&
                      calibration.fixedOffsetKmh == 0.0,
                  liveTheme: liveTheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.applyPreset(SpeedCalibrationConfig.factoryPlus5);
                  },
                ),
                _buildPresetChip(
                  label: 'Factory +8%',
                  isSelected:
                      calibration.isEnabled &&
                      calibration.percentageOffset == 8.0 &&
                      calibration.fixedOffsetKmh == 0.0,
                  liveTheme: liveTheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.applyPreset(SpeedCalibrationConfig.factoryPlus8);
                  },
                ),
                _buildPresetChip(
                  label: 'UNECE (+7% + 2 km/h)',
                  isSelected:
                      calibration.isEnabled &&
                      calibration.percentageOffset == 7.0 &&
                      calibration.fixedOffsetKmh == 2.0,
                  liveTheme: liveTheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.applyPreset(SpeedCalibrationConfig.uneceReg39);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Live HUD Comparison & Simulation Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: liveTheme.isDarkMode
                    ? const Color(0xFF1E2026)
                    : const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: liveTheme.primaryColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'LIVE HUD SIMULATION PREVIEW',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: liveTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildComparisonRow(
                    label: 'Highway Speed (${bench100.round()} $unit true)',
                    hudValue: '${displayBench100.round()} $unit',
                    delta: displayBench100 - bench100,
                    liveTheme: liveTheme,
                  ),
                  const SizedBox(height: 6),
                  _buildComparisonRow(
                    label: 'City Speed (${bench50.round()} $unit true)',
                    hudValue: '${displayBench50.round()} $unit',
                    delta: displayBench50 - bench50,
                    liveTheme: liveTheme,
                  ),
                  const SizedBox(height: 6),
                  _buildComparisonRow(
                    label: 'Stationary (0 $unit stopped at light)',
                    hudValue: '0 $unit',
                    delta: 0,
                    liveTheme: liveTheme,
                    isClampedNote: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Proportional Percentage Offset Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Percentage Offset (Tire / Proportional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: liveTheme.textColor,
                        ),
                      ),
                      Text(
                        'Accounts for tire diameter change or speedometer multiplier',
                        style: TextStyle(
                          fontSize: 11,
                          color: liveTheme.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${calibration.percentageOffset >= 0 ? "+" : ""}${calibration.percentageOffset.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: liveTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 22,
                  ),
                  color: liveTheme.subtitleColor,
                  onPressed: calibration.percentageOffset > -15.0
                      ? () {
                          HapticFeedback.selectionClick();
                          notifier.setCalibration(
                            isEnabled: true,
                            percentageOffset:
                                calibration.percentageOffset - 1.0,
                          );
                        }
                      : null,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: liveTheme.primaryColor,
                      inactiveTrackColor: liveTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      thumbColor: liveTheme.primaryColor,
                      overlayColor: liveTheme.primaryColor.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    child: Slider(
                      value: calibration.percentageOffset.clamp(-15.0, 20.0),
                      min: -15.0,
                      max: 20.0,
                      divisions: 35,
                      label:
                          '${calibration.percentageOffset >= 0 ? "+" : ""}${calibration.percentageOffset.toStringAsFixed(0)}%',
                      onChanged: (val) {
                        notifier.setCalibration(
                          isEnabled: true,
                          percentageOffset: val.roundToDouble(),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  color: liveTheme.subtitleColor,
                  onPressed: calibration.percentageOffset < 20.0
                      ? () {
                          HapticFeedback.selectionClick();
                          notifier.setCalibration(
                            isEnabled: true,
                            percentageOffset:
                                calibration.percentageOffset + 1.0,
                          );
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Fixed Velocity Offset Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fixed Baseline Offset ($unit)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: liveTheme.textColor,
                        ),
                      ),
                      Text(
                        'Constant shift added at moving speeds',
                        style: TextStyle(
                          fontSize: 11,
                          color: liveTheme.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${calibration.fixedOffsetKmh >= 0 ? "+" : ""}${calibration.fixedOffsetKmh.toStringAsFixed(0)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: liveTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 22,
                  ),
                  color: liveTheme.subtitleColor,
                  onPressed: calibration.fixedOffsetKmh > -10.0
                      ? () {
                          HapticFeedback.selectionClick();
                          notifier.setCalibration(
                            isEnabled: true,
                            fixedOffsetKmh: calibration.fixedOffsetKmh - 1.0,
                          );
                        }
                      : null,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: liveTheme.primaryColor,
                      inactiveTrackColor: liveTheme.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      thumbColor: liveTheme.primaryColor,
                      overlayColor: liveTheme.primaryColor.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    child: Slider(
                      value: calibration.fixedOffsetKmh.clamp(-10.0, 10.0),
                      min: -10.0,
                      max: 10.0,
                      divisions: 20,
                      label:
                          '${calibration.fixedOffsetKmh >= 0 ? "+" : ""}${calibration.fixedOffsetKmh.toStringAsFixed(0)} $unit',
                      onChanged: (val) {
                        notifier.setCalibration(
                          isEnabled: true,
                          fixedOffsetKmh: val.roundToDouble(),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                  color: liveTheme.subtitleColor,
                  onPressed: calibration.fixedOffsetKmh < 10.0
                      ? () {
                          HapticFeedback.selectionClick();
                          notifier.setCalibration(
                            isEnabled: true,
                            fixedOffsetKmh: calibration.fixedOffsetKmh + 1.0,
                          );
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Regulation 39 Technical Advisory Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: liveTheme.isDarkMode
                    ? const Color(0xFF141416)
                    : const Color(0xFFF0F0F3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: liveTheme.isDarkMode
                      ? const Color(0xFF262628)
                      : const Color(0xFFE2E2E6),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: liveTheme.subtitleColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Automotive Insight: Under UNECE Regulation 39, factory car speedometers cannot legally underreport speed and typically display 5%–10% higher than actual velocity. Calibration aligns your HUD with your dashboard while ground-truth trip distance remains 100% physically accurate.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: liveTheme.subtitleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required HudTheme liveTheme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? liveTheme.primaryColor.withValues(alpha: 0.18)
              : (liveTheme.isDarkMode
                    ? const Color(0xFF202024)
                    : const Color(0xFFEBEBF0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? liveTheme.primaryColor
                : (liveTheme.isDarkMode
                      ? const Color(0xFF2E2E32)
                      : const Color(0xFFDCDCE0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? liveTheme.primaryColor : liveTheme.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String hudValue,
    required double delta,
    required HudTheme liveTheme,
    bool isClampedNote = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: liveTheme.textColor),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hudValue,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: liveTheme.primaryColor,
              ),
            ),
            if (delta != 0) ...[
              const SizedBox(width: 6),
              Text(
                '(${delta > 0 ? "+" : ""}${delta.round()})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: delta > 0 ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
            ] else if (isClampedNote) ...[
              const SizedBox(width: 6),
              Text(
                '(Lock)',
                style: TextStyle(fontSize: 10, color: liveTheme.subtitleColor),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
