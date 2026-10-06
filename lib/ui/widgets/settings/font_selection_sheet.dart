import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

          // Title & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPEEDOMETER FONT',
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
            'Choose a typography family for glanceable speed numerals',
            style: TextStyle(fontSize: 12, color: liveTheme.subtitleColor),
          ),
          const SizedBox(height: 16),

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
                Text(
                  '104',
                  style: liveTheme.getSpeedTextStyle(
                    fontSize: 48,
                    color: liveTheme.speedNormal,
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
          const SizedBox(height: 16),

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
