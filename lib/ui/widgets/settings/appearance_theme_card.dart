import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';
import 'color_customization_sheet.dart';
import 'font_selection_sheet.dart';

class AppearanceThemeCard extends ConsumerWidget {
  const AppearanceThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final notifier = ref.read(themeConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('APPEARANCE & THEME', theme),
        Material(
          color: theme.cardBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.cardBorderColor),
          ),
          child: Column(
            children: [
              // Theme Mode Selector (Dark AMOLED Default vs Light)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildThemeModeChip(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark (AMOLED)',
                        isSelected: theme.isDarkMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.setThemeMode(isDark: true);
                        },
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildThemeModeChip(
                        icon: Icons.light_mode_rounded,
                        label: 'Light Mode',
                        isSelected: !theme.isDarkMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.setThemeMode(isDark: false);
                        },
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Font Selection Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.speedNormal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.text_fields_rounded,
                      color: theme.speedNormal, size: 20),
                ),
                title: Text(
                  'Speedometer Font',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${config.speedFontFamily} (Tap to change)',
                  style: TextStyle(
                    color: theme.subtitleColor,
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.speedFontFamily,
                      style: TextStyle(
                        color: theme.speedNormal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded,
                        color: theme.subtitleColor),
                  ],
                ),
                onTap: () => FontSelectionSheet.show(context),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Speed Display Colors Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.speedWarning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.palette_outlined,
                      color: theme.speedWarning, size: 20),
                ),
                title: Text(
                  'Speed Display Colors',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Normal, Warning & Critical safety colors',
                  style: TextStyle(
                    color: theme.subtitleColor,
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniColorDot(theme.speedNormal),
                    const SizedBox(width: 4),
                    _buildMiniColorDot(theme.speedWarning),
                    const SizedBox(width: 4),
                    _buildMiniColorDot(theme.speedCritical),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded,
                        color: theme.subtitleColor),
                  ],
                ),
                onTap: () => ColorCustomizationSheet.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.speedNormal
              : (theme.isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF0F0F2)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.speedNormal : theme.cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : theme.textColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
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
              color: theme.speedNormal,
              fontWeight: FontWeight.bold,
            )
            .copyWith(letterSpacing: 0.6),
      ),
    );
  }
}
