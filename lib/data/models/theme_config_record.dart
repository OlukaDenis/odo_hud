import 'package:isar/isar.dart';

part 'theme_config_record.g.dart';

@collection
class ThemeConfigRecord {
  Id id = 1; // Single-row singleton

  int backgroundColorValue = 0xFF020609; // Pure AMOLED Black
  int speedColorNormal = 0xFF028AC4; // Electric Blue (#028ac4)
  int speedColorWarning = 0xFFFFB800; // Amber
  int speedColorCritical = 0xFFFF3B30; // Danger Red
  double warningThresholdKmh = 100.0;
  double criticalThresholdKmh = 130.0;

  int cardBackgroundColor = 0xFF121212;
  int cardBorderColor = 0xFF222222;
  int cardLabelColor = 0xFF888888;
  int cardValueColor = 0xFFFFFFFF;

  String speedFontFamily = 'Inter';
  String telemetryFontFamily = 'Inter';
  bool isMetric = true; // true = km/h, false = mph
  bool onboardingCompleted = false;
}
