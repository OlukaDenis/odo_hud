import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';

class SpeedUnitSelectionSheet extends ConsumerWidget {
  const SpeedUnitSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SpeedUnitSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final notifier = ref.read(themeConfigProvider.notifier);

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
                'Speed Unit',
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
          const SizedBox(height: 16),

          // Selectable Chips
          Row(
            children: [
              _buildChip(
                label: 'KM/H',
                sublabel: 'Metric',
                isSelected: config.isMetric,
                theme: liveTheme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.setUnitSystem(true);
                },
              ),
              const SizedBox(width: 12),
              _buildChip(
                label: 'MPH',
                sublabel: 'Imperial',
                isSelected: !config.isMetric,
                theme: liveTheme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.setUnitSystem(false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? theme.speedNormal : unselectedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? theme.speedNormal : unselectedBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: onAccent,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? onAccent : theme.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }
}
