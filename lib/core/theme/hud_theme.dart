import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/theme_config_record.dart';

class HudTheme {
  final ThemeConfigRecord config;

  HudTheme(this.config);

  Color get backgroundColor => Color(config.backgroundColorValue);
  Color get speedNormal => Color(config.speedColorNormal);
  Color get speedWarning => Color(config.speedColorWarning);
  Color get speedCritical => Color(config.speedColorCritical);

  Color get cardBackgroundColor => Color(config.cardBackgroundColor);
  Color get cardBorderColor => Color(config.cardBorderColor);
  Color get cardLabelColor => Color(config.cardLabelColor);
  Color get cardValueColor => Color(config.cardValueColor);

  double get warningThresholdKmh => config.warningThresholdKmh;
  double get criticalThresholdKmh => config.criticalThresholdKmh;
  bool get isMetric => config.isMetric;

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
      case 'Inter':
        return GoogleFonts.inter().fontFamily ?? 'Inter';
      case 'Poppins':
        return GoogleFonts.poppins().fontFamily ?? 'Poppins';
      case 'Bebas Neue':
        return GoogleFonts.bebasNeue().fontFamily ?? 'Bebas Neue';
      case 'Outfit':
      default:
        return GoogleFonts.outfit().fontFamily ?? 'Outfit';
    }
  }

  TextStyle getSpeedTextStyle({
    required double fontSize,
    required Color color,
  }) {
    TextStyle baseStyle;
    switch (activeFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Inter':
        baseStyle = GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Bebas Neue':
        baseStyle = GoogleFonts.bebasNeue(fontSize: fontSize, fontWeight: FontWeight.normal, color: color);
        break;
      case 'Outfit':
      default:
        baseStyle = GoogleFonts.outfit(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
    }

    return baseStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 2.0,
    );
  }

  TextStyle getTelemetryTextStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    TextStyle baseStyle;
    switch (activeFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Inter':
        baseStyle = GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Bebas Neue':
        baseStyle = GoogleFonts.bebasNeue(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Outfit':
      default:
        baseStyle = GoogleFonts.outfit(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
    }

    return baseStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
