import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';

class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const ThemeSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveTheme = ref.watch(hudThemeProvider);
    final notifier = ref.read(themeConfigProvider.notifier);
    final isDark = liveTheme.isDarkMode;

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
                'THEME APPEARANCE',
                style: liveTheme
                    .getTelemetryTextStyle(
                      fontSize: 16,
                      color: liveTheme.speedNormal,
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
            'Select your preferred display theme for cockpit telemetry',
            style: TextStyle(
              fontSize: 12,
              color: liveTheme.subtitleColor,
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Dark Mode (AMOLED)
          _buildThemeCard(
            title: 'Dark (AMOLED)',
            subtitle: 'Pitch black background with high-contrast surfaces. Ideal for HUD reflection & night driving.',
            icon: Icons.dark_mode_rounded,
            isSelected: isDark,
            previewBgColor: const Color(0xFF000000),
            previewCardColor: const Color(0xFF1E2026),
            previewBorderColor: const Color(0xFF353945),
            previewTextColor: Colors.white,
            theme: liveTheme,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setThemeMode(isDark: true);
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Light Mode
          _buildThemeCard(
            title: 'Light Mode',
            subtitle: 'Crisp light background with elevated white cards. Superior readability in direct sunlight.',
            icon: Icons.light_mode_rounded,
            isSelected: !isDark,
            previewBgColor: const Color(0xFFF5F5F7),
            previewCardColor: const Color(0xFFFFFFFF),
            previewBorderColor: const Color(0xFFE0E0E0),
            previewTextColor: const Color(0xFF111111),
            theme: liveTheme,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setThemeMode(isDark: false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color previewBgColor,
    required Color previewCardColor,
    required Color previewBorderColor,
    required Color previewTextColor,
    required HudTheme theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.speedNormal.withValues(alpha: 0.12)
                : theme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? theme.speedNormal : theme.cardBorderColor,
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              // Mini Cockpit Preview Box
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: previewBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: previewBorderColor, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: previewCardColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: previewBorderColor, width: 1),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isSelected ? theme.speedNormal : previewTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.speedNormal : theme.textColor,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.speedNormal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Radio / Check Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? theme.speedNormal : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? theme.speedNormal : theme.subtitleColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
