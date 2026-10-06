import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/speed_font_size_provider.dart';
import '../../../providers/theme_provider.dart';

class FontSelectionSheet extends ConsumerWidget {
  const FontSelectionSheet({super.key});

  static const List<Map<String, String>> availableFonts = [
    {'name': 'Inter', 'tag': 'Modern & Clean (Default)'},
    {'name': 'Montserrat', 'tag': 'Bold Geometric'},
    {'name': 'Outfit', 'tag': 'High-Tech Minimalist'},
    {'name': 'Poppins', 'tag': 'Smooth Rounded'},
    {'name': 'Orbitron', 'tag': 'Cyberpunk Digital Cockpit'},
    {'name': 'Bebas Neue', 'tag': 'Tall Racing Numerals'},
  ];

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const FontSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final liveConfig = ref.watch(themeConfigProvider);
    final fontScale = ref.watch(speedFontScaleProvider);
    final scaleNotifier = ref.read(speedFontScaleProvider.notifier);
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

          // Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speedometer Font',
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

          // Live Numeral Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: liveTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: liveTheme.cardBorderColor),
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '104',
                    style: liveTheme.getSpeedTextStyle(
                      fontSize: 48.0 * fontScale,
                      color: liveTheme.speedNormal,
                    ),
                  ),
                ),
                Text(
                  liveConfig.isMetric ? 'KM/H' : 'MPH',
                  style: liveTheme.getTelemetryTextStyle(
                    fontSize: 12,
                    color: liveTheme.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Size Stepper Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Numeral Size',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: liveTheme.textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: fontScale > SpeedFontScaleConfig.minScale
                          ? liveTheme.textColor
                          : liveTheme.subtitleColor.withValues(alpha: 0.3),
                      size: 20,
                    ),
                    onPressed: fontScale > SpeedFontScaleConfig.minScale
                        ? () {
                            HapticFeedback.selectionClick();
                            scaleNotifier.decrease();
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: liveTheme.isDarkMode
                          ? const Color(0xFF262830)
                          : const Color(0xFFEFF1F5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: liveTheme.isDarkMode
                            ? const Color(0xFF353945)
                            : const Color(0xFFD6DAE1),
                      ),
                    ),
                    child: Text(
                      '${(fontScale * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: liveTheme.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: fontScale < SpeedFontScaleConfig.maxScale
                          ? liveTheme.textColor
                          : liveTheme.subtitleColor.withValues(alpha: 0.3),
                      size: 20,
                    ),
                    onPressed: fontScale < SpeedFontScaleConfig.maxScale
                        ? () {
                            HapticFeedback.selectionClick();
                            scaleNotifier.increase();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Font Options List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableFonts.length,
              separatorBuilder: (ctx, index) =>
                  Divider(color: liveTheme.dividerColor, height: 1),
              itemBuilder: (ctx, index) {
                final item = availableFonts[index];
                final font = item['name']!;
                final tag = item['tag']!;
                final isSelected = liveConfig.speedFontFamily == font;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    title: Text(
                      font,
                      style: TextStyle(
                        color: isSelected
                            ? liveTheme.speedNormal
                            : liveTheme.textColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected
                            ? liveTheme.speedNormal.withValues(alpha: 0.8)
                            : liveTheme.subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: liveTheme.speedNormal,
                          )
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notifier.updateFonts(speedFont: font);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
