import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/constants/app_colors.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';
import 'package:odo_hud/models/speed_calibration_config.dart';

void main() {
  group('SpeedCalibrationConfig Tests', () {
    test('Disabled calibration returns raw GPS speed', () {
      const config = SpeedCalibrationConfig.gpsTrue;
      expect(config.isEnabled, isFalse);
      expect(config.apply(0.0), equals(0.0));
      expect(config.apply(100.0), equals(100.0));
    });

    test('Stationary vehicle always clamps to 0.0 km/h (Safety Clamp)', () {
      // Even with +10% and +5 km/h, stopped vehicle at red light must read 0.0 km/h
      const config = SpeedCalibrationConfig(
        isEnabled: true,
        percentageOffset: 10.0,
        fixedOffsetKmh: 5.0,
      );

      expect(config.apply(0.0), equals(0.0));
      expect(config.apply(0.0005), equals(0.0));
    });

    test('Proportional percentage calibration (+5% factory offset)', () {
      const config = SpeedCalibrationConfig.factoryPlus5;
      expect(config.isEnabled, isTrue);
      expect(config.percentageOffset, equals(5.0));
      expect(config.fixedOffsetKmh, equals(0.0));

      // 100 km/h * 1.05 = 105.0 km/h
      expect(config.apply(100.0), closeTo(105.0, 0.001));

      // 50 km/h * 1.05 = 52.5 km/h
      expect(config.apply(50.0), closeTo(52.5, 0.001));
    });

    test('UNECE Regulation 39 European standard (+7% + 2 km/h)', () {
      const config = SpeedCalibrationConfig.uneceReg39;
      expect(config.isEnabled, isTrue);
      expect(config.percentageOffset, equals(7.0));
      expect(config.fixedOffsetKmh, equals(2.0));

      // (100 * 1.07) + 2 = 107 + 2 = 109 km/h
      expect(config.apply(100.0), closeTo(109.0, 0.001));

      // (50 * 1.07) + 2 = 53.5 + 2 = 55.5 km/h
      expect(config.apply(50.0), closeTo(55.5, 0.001));
    });

    test('Negative tire circumference delta (-5% aftermarket tire offset)', () {
      const config = SpeedCalibrationConfig(
        isEnabled: true,
        percentageOffset: -5.0,
        fixedOffsetKmh: 0.0,
      );

      // 100 * 0.95 = 95.0 km/h
      expect(config.apply(100.0), closeTo(95.0, 0.001));
    });

    test('summaryText formats cleanly', () {
      expect(
        SpeedCalibrationConfig.gpsTrue.summaryText,
        equals('OFF (True GPS)'),
      );
      expect(SpeedCalibrationConfig.factoryPlus5.summaryText, equals('+5%'));
      expect(
        SpeedCalibrationConfig.uneceReg39.summaryText,
        equals('+7% +2 km/h'),
      );
    });
  });

  group('Global Primary Color Tests', () {
    test('AppColors.primaryColor is defaultSpeedColor', () {
      expect(AppColors.primaryColor, equals(AppColors.defaultSpeedColor));
      expect(AppColors.primaryColor.toARGB32(), equals(0xFFFFFFFF));
    });

    test('HudTheme.primaryColor matches speedNormal', () {
      final config = ThemeConfigRecord()..speedColorNormal = 0xFFFFFFFF;
      final theme = HudTheme(config);
      expect(theme.primaryColor, equals(theme.speedNormal));
      expect(theme.primaryColor, equals(AppColors.defaultSpeedColor));

      // User changes primary color to custom Neon Green
      config.speedColorNormal = 0xFF00FF66;
      final updatedTheme = HudTheme(config);
      expect(updatedTheme.primaryColor, equals(const Color(0xFF00FF66)));
      expect(updatedTheme.speedNormal, equals(const Color(0xFF00FF66)));
    });
  });
}
