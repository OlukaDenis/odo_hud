import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/hud_theme.dart';
import '../data/database/isar_service.dart';
import '../data/models/theme_config_record.dart';

final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, ThemeConfigRecord>((ref) {
  return ThemeConfigNotifier();
});

final hudThemeProvider = Provider<HudTheme>((ref) {
  final config = ref.watch(themeConfigProvider);
  return HudTheme(config);
});

class ThemeConfigNotifier extends StateNotifier<ThemeConfigRecord> {
  Timer? _saveDebounceTimer;

  ThemeConfigNotifier() : super(ThemeConfigRecord()..id = 1) {
    _load();
  }

  static ThemeConfigRecord _clone(ThemeConfigRecord src) {
    return ThemeConfigRecord()
      ..id = src.id
      ..backgroundColorValue = src.backgroundColorValue
      ..speedColorNormal = src.speedColorNormal
      ..speedColorWarning = src.speedColorWarning
      ..speedColorCritical = src.speedColorCritical
      ..warningThresholdKmh = src.warningThresholdKmh
      ..criticalThresholdKmh = src.criticalThresholdKmh
      ..cardBackgroundColor = src.cardBackgroundColor
      ..cardBorderColor = src.cardBorderColor
      ..cardLabelColor = src.cardLabelColor
      ..cardValueColor = src.cardValueColor
      ..speedFontFamily = src.speedFontFamily
      ..telemetryFontFamily = src.telemetryFontFamily
      ..isMetric = src.isMetric
      ..onboardingCompleted = src.onboardingCompleted;
  }

  Future<void> _load() async {
    final record = await IsarService.instance.getThemeConfig();
    // Auto-migrate legacy low-contrast dark card backgrounds to high-contrast surface
    if (record.backgroundColorValue == 0xFF000000 &&
        (record.cardBackgroundColor == 0xFF121212 ||
            record.cardBackgroundColor == 0xFF141414)) {
      record.cardBackgroundColor = 0xFF1E2026;
      record.cardBorderColor = 0xFF353945;
      record.cardLabelColor = 0xFF9E9EB2;
      unawaited(IsarService.instance.saveThemeConfig(record));
    }
    state = record;
  }

  void _debounceSave({Duration delay = const Duration(milliseconds: 150)}) {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(delay, () async {
      try {
        await IsarService.instance.saveThemeConfig(state);
      } catch (e) {
        debugPrint('Error saving theme config in background: $e');
      }
    });
  }

  void updateBackgroundColor(int colorValue) {
    final updated = _clone(state);
    updated.backgroundColorValue = colorValue;
    state = updated;
    _debounceSave();
  }

  void setThemeMode({required bool isDark}) {
    final updated = _clone(state);
    if (isDark) {
      updated.backgroundColorValue = 0xFF000000; // Pure AMOLED Black
      updated.cardBackgroundColor = 0xFF1E2026; // High-contrast elevated dark surface
      updated.cardBorderColor = 0xFF353945;     // Crisp distinctive card border
      updated.cardLabelColor = 0xFF9E9EB2;      // Clear high-contrast labels for poor vision
      updated.cardValueColor = 0xFFFFFFFF;
    } else {
      updated.backgroundColorValue = 0xFFF5F5F7; // Clean Modern Light
      updated.cardBackgroundColor = 0xFFFFFFFF;
      updated.cardBorderColor = 0xFFE0E0E0;
      updated.cardLabelColor = 0xFF666666;
      updated.cardValueColor = 0xFF121212;
    }
    state = updated;
    _debounceSave();
  }

  void updateSpeedColors({
    int? normal,
    int? warning,
    int? critical,
  }) {
    final updated = _clone(state);
    if (normal != null) updated.speedColorNormal = normal;
    if (warning != null) updated.speedColorWarning = warning;
    if (critical != null) updated.speedColorCritical = critical;
    state = updated;
    _debounceSave();
  }

  void updateSpeedThresholds({
    double? warningKmh,
    double? criticalKmh,
  }) {
    final updated = _clone(state);
    if (warningKmh != null) updated.warningThresholdKmh = warningKmh;
    if (criticalKmh != null) updated.criticalThresholdKmh = criticalKmh;
    state = updated;
    _debounceSave(delay: const Duration(milliseconds: 250));
  }

  void updateFonts({
    String? speedFont,
    String? telemetryFont,
  }) {
    final updated = _clone(state);
    final chosen = speedFont ?? telemetryFont;
    if (chosen != null) {
      updated.speedFontFamily = chosen;
      updated.telemetryFontFamily = chosen;
    }
    state = updated;
    _debounceSave();
  }

  void setUnitSystem(bool isMetric) {
    if (state.isMetric == isMetric) return;
    final updated = _clone(state);
    updated.isMetric = isMetric;

    // Convert thresholds when switching between metric and imperial
    if (!isMetric) {
      // km/h -> mph
      updated.warningThresholdKmh =
          (updated.warningThresholdKmh * 0.621371).roundToDouble();
      updated.criticalThresholdKmh =
          (updated.criticalThresholdKmh * 0.621371).roundToDouble();
    } else {
      // mph -> km/h
      updated.warningThresholdKmh =
          (updated.warningThresholdKmh / 0.621371).roundToDouble();
      updated.criticalThresholdKmh =
          (updated.criticalThresholdKmh / 0.621371).roundToDouble();
    }

    state = updated;
    _debounceSave();
  }

  void toggleUnitSystem() {
    setUnitSystem(!state.isMetric);
  }

  void updateCardColors({
    int? background,
    int? border,
    int? label,
    int? value,
  }) {
    final updated = _clone(state);
    if (background != null) updated.cardBackgroundColor = background;
    if (border != null) updated.cardBorderColor = border;
    if (label != null) updated.cardLabelColor = label;
    if (value != null) updated.cardValueColor = value;
    state = updated;
    _debounceSave();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}
