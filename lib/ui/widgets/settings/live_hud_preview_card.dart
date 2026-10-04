import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';
import '../speed_display.dart';

class LiveHudPreviewCard extends ConsumerWidget {
  const LiveHudPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('LIVE HUD PREVIEW', theme),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.cardBorderColor, width: 2),
          ),
          child: Center(
            child: SpeedDisplay(
              currentSpeed: config.isMetric ? 104 : 65,
              speedKmh: 104,
              isMetric: config.isMetric,
              theme: theme,
            ),
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
