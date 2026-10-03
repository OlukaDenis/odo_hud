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

  Color getSpeedColor(double speedKmh) {
    if (speedKmh >= config.criticalThresholdKmh) {
      return speedCritical;
    } else if (speedKmh >= config.warningThresholdKmh) {
      return speedWarning;
    } else {
      return speedNormal;
    }
  }

  TextStyle getSpeedTextStyle({
    required double fontSize,
    required Color color,
  }) {
    TextStyle baseStyle;
    switch (config.speedFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: fontSize, fontWeight: FontWeight.w900, color: color);
        break;
      case 'Share Tech Mono':
        baseStyle = GoogleFonts.shareTechMono(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
        break;
      case 'JetBrains Mono':
        baseStyle = GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: FontWeight.w800, color: color);
        break;
      case 'Bebas Neue':
      default:
        baseStyle = GoogleFonts.bebasNeue(fontSize: fontSize, fontWeight: FontWeight.normal, color: color);
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
    switch (config.telemetryFontFamily) {
      case 'Orbitron':
        baseStyle = GoogleFonts.orbitron(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Bebas Neue':
        baseStyle = GoogleFonts.bebasNeue(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'Share Tech Mono':
        baseStyle = GoogleFonts.shareTechMono(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
      case 'JetBrains Mono':
      default:
        baseStyle = GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: fontWeight, color: color);
        break;
    }

    return baseStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
