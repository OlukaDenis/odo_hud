import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';
import 'color_picker_dialog.dart';

class ColorCustomizationSheet extends ConsumerWidget {
  const ColorCustomizationSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const ColorCustomizationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final notifier = ref.read(themeConfigProvider.notifier);

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
                'COLORS',
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
            'Personalize the 3-stage velocity alert color palette',
            style: TextStyle(fontSize: 12, color: liveTheme.subtitleColor),
          ),
          const SizedBox(height: 20),

          // 1. App Primary & Normal Speed Color
          _buildColorSelectionTile(
            context: context,
            title: 'App Primary & Normal Speed Color',
            subtitle: 'Global primary accent & cruising speedometer color',
            currentColor: liveTheme.speedNormal,
            presets: const [
              Color(0xFF028AC4), // Electric Cyan / Blue (#028ac4)
              Color(0xFF00FF66), // Electric Green
              Color(0xFF00E5FF), // Cyan Accent
              Color(0xFF76FF03), // Neon Lime
              Color(0xFFFFFFFF), // Pure White
            ],
            onSelectPreset: (c) =>
                notifier.updateSpeedColors(normal: c.toARGB32()),
            onOpenPicker: () => showHudColorPicker(
              context: context,
              title: 'Select Normal Speed Color',
              currentColor: liveTheme.speedNormal,
              onColorChanged: (c) =>
                  notifier.updateSpeedColors(normal: c.toARGB32()),
              isDark: liveTheme.isDarkMode,
            ),
            theme: liveTheme,
          ),
          Divider(color: liveTheme.dividerColor, height: 24),

          // 2. Warning Speed Color
          _buildColorSelectionTile(
            context: context,
            title: 'Warning Speed Color',
            subtitle: 'Approaching highway / zone limits',
            currentColor: liveTheme.speedWarning,
            presets: const [
              Color(0xFFFFB800), // Amber
              Color(0xFFFF9100), // Neon Orange
              Color(0xFFFFD600), // Gold
              Color(0xFFFFEA00), // Bright Yellow
            ],
            onSelectPreset: (c) =>
                notifier.updateSpeedColors(warning: c.toARGB32()),
            onOpenPicker: () => showHudColorPicker(
              context: context,
              title: 'Select Warning Speed Color',
              currentColor: liveTheme.speedWarning,
              onColorChanged: (c) =>
                  notifier.updateSpeedColors(warning: c.toARGB32()),
              isDark: liveTheme.isDarkMode,
            ),
            theme: liveTheme,
          ),
          Divider(color: liveTheme.dividerColor, height: 24),

          // 3. Critical Speed Color
          _buildColorSelectionTile(
            context: context,
            title: 'Critical Speed Color',
            subtitle: 'Velocity exceeding max safety limit',
            currentColor: liveTheme.speedCritical,
            presets: const [
              Color(0xFFFF3B30), // Danger Red
              Color(0xFFFF1744), // Crimson
              Color(0xFFFF0055), // Hot Pink Red
              Color(0xFFD50000), // Deep Red
            ],
            onSelectPreset: (c) =>
                notifier.updateSpeedColors(critical: c.toARGB32()),
            onOpenPicker: () => showHudColorPicker(
              context: context,
              title: 'Select Critical Speed Color',
              currentColor: liveTheme.speedCritical,
              onColorChanged: (c) =>
                  notifier.updateSpeedColors(critical: c.toARGB32()),
              isDark: liveTheme.isDarkMode,
            ),
            theme: liveTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelectionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color currentColor,
    required List<Color> presets,
    required ValueChanged<Color> onSelectPreset,
    required VoidCallback onOpenPicker,
    required HudTheme theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.subtitleColor, fontSize: 11),
                ),
              ],
            ),
            GestureDetector(
              onTap: onOpenPicker,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.textColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ...presets.map((color) {
              final isSelected = currentColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectPreset(color);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : null,
                ),
              );
            }),
            const Spacer(),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                side: BorderSide(color: theme.cardBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.colorize_rounded,
                size: 14,
                color: theme.textColor,
              ),
              label: Text(
                'Custom',
                style: TextStyle(fontSize: 11, color: theme.textColor),
              ),
              onPressed: onOpenPicker,
            ),
          ],
        ),
      ],
    );
  }
}
