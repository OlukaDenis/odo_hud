import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/speed_font_size_provider.dart';
import '../../../providers/theme_provider.dart';

class SpeedFontSizeSheet extends ConsumerWidget {
  const SpeedFontSizeSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SpeedFontSizeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final liveConfig = ref.watch(themeConfigProvider);
    final fontScale = ref.watch(speedFontScaleProvider);
    final notifier = ref.read(speedFontScaleProvider.notifier);
    final percent = (fontScale * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: liveTheme.isDarkMode
            ? const Color(0xFF1E2026)
            : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: liveTheme.isDarkMode
              ? const Color(0xFF353945)
              : const Color(0xFFE5E5EA),
          width: 1.2,
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

          // Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speed Font Size',
                style: liveTheme
                    .getTelemetryTextStyle(
                      fontSize: 16,
                      color: liveTheme.textColor,
                      fontWeight: FontWeight.bold,
                    )
                    .copyWith(letterSpacing: 0.5),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: liveTheme.subtitleColor),
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Preview Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: liveTheme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: liveTheme.isDarkMode
                    ? const Color(0xFF353945)
                    : const Color(0xFFE5E5EA),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      liveConfig.isMetric ? '104' : '65',
                      style: liveTheme.getSpeedTextStyle(
                        fontSize: 56.0 * fontScale,
                        color: liveTheme.speedNormal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    liveConfig.isMetric ? 'KM/H' : 'MPH',
                    style: liveTheme.getTelemetryTextStyle(
                      fontSize: 12,
                      color: liveTheme.subtitleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stepper Row: [-] [100%] [+]
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepButton(
                icon: Icons.remove_rounded,
                isEnabled: fontScale > SpeedFontScaleConfig.minScale,
                theme: liveTheme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.decrease();
                },
              ),
              const SizedBox(width: 20),
              Container(
                constraints: const BoxConstraints(minWidth: 84),
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: liveTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildStepButton(
                icon: Icons.add_rounded,
                isEnabled: fontScale < SpeedFontScaleConfig.maxScale,
                theme: liveTheme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.increase();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Presets: Selectable Chips with Solid Background
          Row(
            children: SpeedFontScaleConfig.presets.map((preset) {
              final presetScale = preset['scale'] as double;
              final label = preset['label'] as String;
              final sublabel = preset['sublabel'] as String;
              final isSelected = (fontScale - presetScale).abs() < 0.02;

              return _buildPresetChip(
                label: label,
                sublabel: sublabel,
                isSelected: isSelected,
                theme: liveTheme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.setScale(presetScale);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Fine adjustment slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: liveTheme.speedNormal,
              inactiveTrackColor: liveTheme.isDarkMode
                  ? const Color(0xFF2E313D)
                  : const Color(0xFFE2E4E9),
              thumbColor: liveTheme.speedNormal,
              overlayColor: liveTheme.speedNormal.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: fontScale.clamp(
                SpeedFontScaleConfig.minScale,
                SpeedFontScaleConfig.maxScale,
              ),
              min: SpeedFontScaleConfig.minScale,
              max: SpeedFontScaleConfig.maxScale,
              divisions: 12,
              onChanged: (val) {
                notifier.setScale(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool isEnabled,
    required HudTheme theme,
    required VoidCallback onTap,
  }) {
    final bg = theme.isDarkMode
        ? const Color(0xFF262830)
        : const Color(0xFFEFF1F5);
    final border = theme.isDarkMode
        ? const Color(0xFF353945)
        : const Color(0xFFD6DAE1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isEnabled
                ? theme.textColor
                : theme.subtitleColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String sublabel,
    required bool isSelected,
    required HudTheme theme,
    required VoidCallback onTap,
  }) {
    final isDarkAccent =
        ThemeData.estimateBrightnessForColor(theme.speedNormal) ==
        Brightness.dark;
    final onAccent = isDarkAccent ? Colors.white : const Color(0xFF111111);
    final onAccentSub =
        isDarkAccent ? Colors.white70 : const Color(0x99111111);

    final unselectedBg = theme.isDarkMode
        ? const Color(0xFF262830)
        : const Color(0xFFEFF1F5);
    final unselectedBorder = theme.isDarkMode
        ? const Color(0xFF353945)
        : const Color(0xFFD6DAE1);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? theme.speedNormal : unselectedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? theme.speedNormal : unselectedBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? onAccent : theme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? onAccentSub : theme.subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
