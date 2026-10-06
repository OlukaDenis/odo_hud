import 'package:flutter/material.dart';

import '../../core/theme/hud_theme.dart';

class SpeedDisplay extends StatelessWidget {
  final double currentSpeed;
  final double speedKmh;
  final bool isMetric;
  final HudTheme theme;
  final double? customFontSize;

  const SpeedDisplay({
    super.key,
    required this.currentSpeed,
    required this.speedKmh,
    required this.isMetric,
    required this.theme,
    this.customFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final unitText = isMetric ? 'KM / H' : 'MPH';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: currentSpeed, end: currentSpeed),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, animatedSpeed, child) {
        final speedColor = theme.getSpeedColor(speedKmh);
        final speedText = animatedSpeed.round().toString();

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive font size if not explicitly provided
            final availableHeight = constraints.maxHeight;
            final calculatedSize = (availableHeight * 0.55).clamp(64.0, 220.0);
            final fontSize = customFontSize ?? calculatedSize;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Speed Numeral
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    speedText,
                    style: theme
                        .getSpeedTextStyle(
                          fontSize: fontSize,
                          color: speedColor,
                        )
                        .copyWith(
                          shadows: [
                            Shadow(
                              color: speedColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                  ),
                ),

                // Speed Unit Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  child: Text(
                    unitText,
                    style: theme
                        .getTelemetryTextStyle(
                          fontSize: 14,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                        )
                        .copyWith(letterSpacing: 1.0),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
