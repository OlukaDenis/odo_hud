import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../providers/theme_provider.dart';

class SpeedUnitCard extends ConsumerWidget {
  const SpeedUnitCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final notifier = ref.read(themeConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('SPEED UNIT SYSTEM', theme),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.cardBorderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildUnitChip(
                  label: 'KM/H',
                  sublabel: 'Kilometers per hour',
                  isSelected: config.isMetric,
                  onTap: () => notifier.setUnitSystem(true),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildUnitChip(
                  label: 'MPH',
                  sublabel: 'Miles per hour',
                  isSelected: !config.isMetric,
                  onTap: () => notifier.setUnitSystem(false),
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitChip({
    required String label,
    required String sublabel,
    required bool isSelected,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.speedNormal.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : theme.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.black87 : theme.subtitleColor,
              ),
            ),
          ],
        ),
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
