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
  ThemeConfigNotifier() : super(ThemeConfigRecord()..id = 1) {
    _load();
  }

  Future<void> _load() async {
    final record = await IsarService.instance.getThemeConfig();
    state = record;
  }

  Future<void> updateBackgroundColor(int colorValue) async {
    state.backgroundColorValue = colorValue;
    await _save();
  }

  Future<void> updateSpeedColors({
    int? normal,
    int? warning,
    int? critical,
  }) async {
    if (normal != null) state.speedColorNormal = normal;
    if (warning != null) state.speedColorWarning = warning;
    if (critical != null) state.speedColorCritical = critical;
    await _save();
  }

  Future<void> updateSpeedThresholds({
    double? warningKmh,
    double? criticalKmh,
  }) async {
    if (warningKmh != null) state.warningThresholdKmh = warningKmh;
    if (criticalKmh != null) state.criticalThresholdKmh = criticalKmh;
    await _save();
  }

  Future<void> updateFonts({
    String? speedFont,
    String? telemetryFont,
  }) async {
    if (speedFont != null) state.speedFontFamily = speedFont;
    if (telemetryFont != null) state.telemetryFontFamily = telemetryFont;
    await _save();
  }

  Future<void> toggleUnitSystem() async {
    state.isMetric = !state.isMetric;
    await _save();
  }

  Future<void> updateCardColors({
    int? background,
    int? border,
    int? label,
    int? value,
  }) async {
    if (background != null) state.cardBackgroundColor = background;
    if (border != null) state.cardBorderColor = border;
    if (label != null) state.cardLabelColor = label;
    if (value != null) state.cardValueColor = value;
    await _save();
  }

  Future<void> _save() async {
    await IsarService.instance.saveThemeConfig(state);
    // Trigger state change notification by cloning or reassigning
    final updated = await IsarService.instance.getThemeConfig();
    state = updated;
  }
}
