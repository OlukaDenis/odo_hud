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
                'SPEED UNIT SYSTEM',
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
            'Choose the speed measurement unit for glanceable speedometer telemetry',
            style: TextStyle(
              fontSize: 12,
              color: liveTheme.subtitleColor,
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: KM/H
          _buildOptionCard(
            title: 'KM/H (Metric)',
            subtitle: 'Kilometers per hour. Global standard for velocity & telemetry.',
            badge: 'KM/H',
            isSelected: config.isMetric,
            theme: liveTheme,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setUnitSystem(true);
            },
          ),
          const SizedBox(height: 12),

          // Option 2: MPH
          _buildOptionCard(
            title: 'MPH (Imperial)',
            subtitle: 'Miles per hour. Standard in the United States and United Kingdom.',
            badge: 'MPH',
            isSelected: !config.isMetric,
            theme: liveTheme,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setUnitSystem(false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String badge,
    required bool isSelected,
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
              // Badge Icon Box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.speedNormal.withValues(alpha: 0.18)
                      : (theme.isDarkMode
                          ? const Color(0xFF16181D)
                          : const Color(0xFFF2F2F7)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? theme.speedNormal : theme.cardBorderColor,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? theme.speedNormal : theme.textColor,
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
