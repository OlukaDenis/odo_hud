import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../screens/permissions_screen.dart';

class PermissionsNavCard extends ConsumerWidget {
  const PermissionsNavCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('PERMISSIONS & SYSTEM TUNING', theme),
        Material(
          color: theme.cardBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.cardBorderColor),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.speedNormal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: theme.speedNormal, size: 20),
            ),
            title: Text(
              'Hardware & Background Access',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              'GPS Location, HUD notification & OEM battery guide',
              style: TextStyle(
                color: theme.subtitleColor,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.speedNormal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Manage',
                    style: TextStyle(
                      color: theme.speedNormal,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: theme.subtitleColor),
              ],
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              try {
                context.push('/permissions');
              } catch (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PermissionsScreen(),
                  ),
                );
              }
            },
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
              color: theme.speedNormal,
              fontWeight: FontWeight.bold,
            )
            .copyWith(letterSpacing: 0.6),
      ),
    );
  }
}
