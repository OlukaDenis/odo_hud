import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/speed_font_size_provider.dart';
import '../../../providers/theme_provider.dart';
import 'color_customization_sheet.dart';
import 'font_selection_sheet.dart';
import 'speed_font_size_sheet.dart';
import 'theme_selection_sheet.dart';

class AppearanceThemeCard extends ConsumerWidget {
  const AppearanceThemeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final fontScale = ref.watch(speedFontScaleProvider);
    final scaleNotifier = ref.read(speedFontScaleProvider.notifier);

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
              // Theme Mode Selector Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    theme.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: theme.textColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Theme Appearance',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  theme.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(color: theme.subtitleColor, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.speedNormal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        theme.isDarkMode ? 'DARK' : 'LIGHT',
                        style: TextStyle(
                          color: theme.speedNormal,
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
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
                onTap: () => ThemeSelectionSheet.show(context),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Font Selection Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.text_fields_rounded,
                    color: theme.textColor,
                    size: 20,
                  ),
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
                  style: TextStyle(color: theme.subtitleColor, fontSize: 12),
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.subtitleColor,
                    ),
                  ],
                ),
                onTap: () => FontSelectionSheet.show(context),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Speed Font Size Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.format_size_rounded,
                    color: theme.textColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Speed Font Size',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${(fontScale * 100).round()}% scale (Tap to adjust)',
                  style: TextStyle(color: theme.subtitleColor, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: fontScale > SpeedFontScaleConfig.minScale
                          ? () {
                              HapticFeedback.selectionClick();
                              scaleNotifier.decrease();
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 18,
                          color: fontScale > SpeedFontScaleConfig.minScale
                              ? theme.textColor
                              : theme.subtitleColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.speedNormal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(fontScale * 100).round()}%',
                        style: TextStyle(
                          color: theme.speedNormal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: fontScale < SpeedFontScaleConfig.maxScale
                          ? () {
                              HapticFeedback.selectionClick();
                              scaleNotifier.increase();
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: fontScale < SpeedFontScaleConfig.maxScale
                              ? theme.textColor
                              : theme.subtitleColor.withValues(alpha: 0.3),
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
                onTap: () => SpeedFontSizeSheet.show(context),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Speed Display Colors Tile (Opens Bottom Sheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: theme.textColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Display Colors',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'App-wide primary color, warning & critical alerts',
                  style: TextStyle(color: theme.subtitleColor, fontSize: 12),
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.subtitleColor,
                    ),
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
              color: theme.subtitleColor,
              fontWeight: FontWeight.normal,
            )
            .copyWith(letterSpacing: 0.2),
      ),
    );
  }
}
