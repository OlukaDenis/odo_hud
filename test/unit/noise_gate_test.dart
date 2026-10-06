import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/constants/app_colors.dart';
import 'package:odo_hud/core/constants/app_constants.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';

void main() {
  group('Noise Gate & Threshold Tests', () {
    test('Noise gate threshold constants', () {
      expect(AppConstants.minMovingSpeedMps, closeTo(0.222222, 0.0001));
      expect(AppConstants.minMovingSpeedKmh, equals(0.8));
      expect(AppConstants.maxAcceptableGpsAccuracyMeters, equals(20.0));
      expect(AppConstants.gpsTimeoutSeconds, equals(3));
    });

    test('HudTheme getSpeedColor thresholds', () {
      final config = ThemeConfigRecord()
        ..id = 1
        ..warningThresholdKmh = 100.0
        ..criticalThresholdKmh = 130.0
        ..speedColorNormal = AppColors.electricGreen.toARGB32()
        ..speedColorWarning = AppColors.warningAmber.toARGB32()
        ..speedColorCritical = AppColors.criticalRed.toARGB32();

      final theme = HudTheme(config);

      // Normal speed (< 100 km/h)
      expect(theme.getSpeedColor(0.0), equals(AppColors.electricGreen));
      expect(theme.getSpeedColor(50.0), equals(AppColors.electricGreen));
      expect(theme.getSpeedColor(99.9), equals(AppColors.electricGreen));

      // Warning speed (>= 100 km/h and < 130 km/h)
      expect(theme.getSpeedColor(100.0), equals(AppColors.warningAmber));
      expect(theme.getSpeedColor(115.0), equals(AppColors.warningAmber));
      expect(theme.getSpeedColor(129.9), equals(AppColors.warningAmber));

      // Critical speed (>= 130 km/h)
      expect(theme.getSpeedColor(130.0), equals(AppColors.criticalRed));
      expect(theme.getSpeedColor(180.0), equals(AppColors.criticalRed));
    });
  });
}
