import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/theme_config_record.dart';

class HudTheme {
  final ThemeConfigRecord config;

  HudTheme(this.config);

  Color get backgroundColor => Color(config.backgroundColorValue);
  Color get speedNormal => Color(config.speedColorNormal);
  /// The app's global primary theme accent, user-configurable from speedNormal
  Color get primaryColor => speedNormal;
  Color get speedWarning => Color(config.speedColorWarning);
  Color get speedCritical => Color(config.speedColorCritical);

  Color get cardBackgroundColor => Color(config.cardBackgroundColor);
  Color get cardBorderColor => Color(config.cardBorderColor);
  Color get cardLabelColor => Color(config.cardLabelColor);
  Color get cardValueColor => Color(config.cardValueColor);

  double get warningThresholdKmh => config.warningThresholdKmh;
  double get criticalThresholdKmh => config.criticalThresholdKmh;
  bool get isMetric => config.isMetric;
  String get distanceUnit => config.distanceUnit;
  bool get isDistanceKm => config.distanceUnit == 'km';

  bool get isDarkMode =>
      config.backgroundColorValue == 0xFF000000 ||
      ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF111111);
  Color get subtitleColor =>
      isDarkMode ? Colors.white60 : const Color(0xFF666666);
  Color get dividerColor =>
      isDarkMode ? Colors.white12 : const Color(0x1F000000);

  String get activeFontFamily => config.speedFontFamily;

  Color getSpeedColor(double speedKmh) {
    if (speedKmh >= config.criticalThresholdKmh) {
      return speedCritical;
    } else if (speedKmh >= config.warningThresholdKmh) {
      return speedWarning;
    } else {
      return speedNormal;
    }
  }

  /// Resolves the app-wide fontFamily string using the chosen non-mono font
  String get fontFamily {
    switch (activeFontFamily) {
      case 'Orbitron':
        return GoogleFonts.orbitron().fontFamily ?? 'Orbitron';
      case 'Montserrat':
        return GoogleFonts.montserrat().fontFamily ?? 'Montserrat';
      case 'Outfit':
        return GoogleFonts.outfit().fontFamily ?? 'Outfit';
      case 'Poppins':
        return GoogleFonts.poppins().fontFamily ?? 'Poppins';
      case 'Bebas Neue':
        return GoogleFonts.bebasNeue().fontFamily ?? 'Bebas Neue';
      case 'Inter':
      default:
        return GoogleFonts.inter().fontFamily ?? 'Inter';
    }
  }

  TextStyle getSpeedTextStyle({
    required num fontSize,
    required Color color,
  }) {
    final size = fontSize.toDouble();
    TextStyle baseStyle;
    switch (activeFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: size, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(fontSize: size, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Outfit':
        baseStyle = GoogleFonts.outfit(fontSize: size, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins(fontSize: size, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Bebas Neue':
        baseStyle = GoogleFonts.bebasNeue(fontSize: size, fontWeight: FontWeight.normal, color: color);
        break;
      case 'Inter':
      default:
        baseStyle = GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w900, color: color);
        break;
    }

    return baseStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 2.0,
    );
  }

  TextStyle getTelemetryTextStyle({
    required num fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
    double? letterSpacing,
    double? height,
  }) {
    final size = fontSize.toDouble();
    TextStyle baseStyle;
    switch (activeFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: size, fontWeight: fontWeight, color: color);
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(fontSize: size, fontWeight: fontWeight, color: color);
        break;
      case 'Outfit':
        baseStyle = GoogleFonts.outfit(fontSize: size, fontWeight: fontWeight, color: color);
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins(fontSize: size, fontWeight: fontWeight, color: color);
        break;
      case 'Bebas Neue':
        baseStyle = GoogleFonts.bebasNeue(fontSize: size, fontWeight: fontWeight, color: color);
        break;
      case 'Inter':
      default:
        baseStyle = GoogleFonts.inter(fontSize: size, fontWeight: fontWeight, color: color);
        break;
    }

    return baseStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
