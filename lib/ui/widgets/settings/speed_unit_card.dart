import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';
import 'distance_unit_selection_sheet.dart';
import 'speed_unit_selection_sheet.dart';

class SpeedUnitCard extends ConsumerWidget {
  const SpeedUnitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SPEED & DISTANCE UNITS', theme),
        Material(
          color: theme.cardBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.cardBorderColor),
          ),
          child: Column(
            children: [
              // Speed Unit Tile (Opens SpeedUnitSelectionSheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: theme.textColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Speed Unit',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  config.isMetric
                      ? 'Kilometers per hour (KM/H)'
                      : 'Miles per hour (MPH)',
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
                        config.isMetric ? 'KM/H' : 'MPH',
                        style: TextStyle(
                          color: theme.speedNormal,
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
                onTap: () => SpeedUnitSelectionSheet.show(context),
              ),
              Divider(color: theme.dividerColor, height: 1),

              // Distance Unit Tile (Opens DistanceUnitSelectionSheet)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.straighten_rounded,
                    color: theme.textColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Distance Unit',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  config.distanceUnit == 'km'
                      ? 'Kilometers (km)'
                      : 'Meters (m)',
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
                        config.distanceUnit.toUpperCase(),
                        style: TextStyle(
                          color: theme.speedNormal,
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
                onTap: () => DistanceUnitSelectionSheet.show(context),
              ),
            ],
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
