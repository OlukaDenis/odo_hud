import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/hud_theme.dart';
import '../../../models/telemetry_state.dart';
import 'compass_bottom_sheet.dart';
import 'compass_dial.dart';

/// Compact Compass Metric Card displayed in the Auxiliary Grid.
/// Displays a mini animated two-hand compass gauge, heading degrees,
/// and tap-to-expand affordance to open the detailed Compass Bottom Sheet.
class CompassCard extends StatelessWidget {
  final TelemetryState telemetry;
  final HudTheme theme;
  final bool isMetric;

  const CompassCard({
    super.key,
    required this.telemetry,
    required this.theme,
    required this.isMetric,
  });

  void _openExpandedCompass(BuildContext context) {
    HapticFeedback.selectionClick();
    CompassBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.cardBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _openExpandedCompass(context),
        borderRadius: BorderRadius.circular(10),
        splashColor: theme.speedNormal.withValues(alpha: 0.15),
        highlightColor: theme.speedNormal.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.cardBackgroundColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Label & Expand Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Heading',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme
                          .getTelemetryTextStyle(
                            fontSize: 11,
                            color: theme.cardLabelColor,
                            fontWeight: FontWeight.w600,
                          )
                          .copyWith(letterSpacing: 0.2),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_full_rounded,
                        size: 11,
                        color: theme.cardLabelColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ],
              ),

              // Body: Centered Mini 2-Hand Compass Dial
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: CompassDial(
                        headingDegrees: telemetry.headingDegrees,
                        size: 60,
                        isMini: true,
                        theme: theme,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
