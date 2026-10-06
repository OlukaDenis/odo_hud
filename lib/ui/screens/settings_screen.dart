import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../widgets/settings/about_info_card.dart';
import '../widgets/settings/appearance_theme_card.dart';
import '../widgets/settings/permissions_nav_card.dart';
import '../widgets/settings/speed_alerts_card.dart';
import '../widgets/settings/speed_calibration_card.dart';
import '../widgets/settings/speed_unit_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardBackgroundColor,
        elevation: 0,
        title: Text(
          'HUD SETTINGS',
          style: theme.getTelemetryTextStyle(
            fontSize: 17.0,
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const [
          // 1. SPEED UNIT SYSTEM (TOP OF SCREEN - KM/H DEFAULT)
          SpeedUnitCard(),
          SizedBox(height: 20),

          // 2. SPEEDOMETER CALIBRATION OFFSET & TIRE SIZING (UNECE REG 39)
          SpeedCalibrationCard(),
          SizedBox(height: 20),

          // 3. APPEARANCE & THEME (DARK AMOLED DEFAULT VS LIGHT, FONTS, COLORS)
          AppearanceThemeCard(),
          SizedBox(height: 20),

          // 4. SPEED ALERTS & SAFETY (SPEED THRESHOLDS)
          SpeedAlertsCard(),
          SizedBox(height: 20),

          // 5. PERMISSIONS & SYSTEM TUNING (SEPARATE SCREEN NAVIGATION)
          PermissionsNavCard(),
          SizedBox(height: 20),

          // 6. ABOUT & GENERAL INFO
          AboutInfoCard(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
