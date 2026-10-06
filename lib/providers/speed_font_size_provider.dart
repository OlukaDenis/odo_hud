import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeedFontScaleConfig {
  static const double minScale = 0.75;
  static const double maxScale = 1.35;
  static const double step = 0.05;
  static const double defaultScale = 1.0;

  static const List<Map<String, dynamic>> presets = [
    {'label': 'Small', 'sublabel': '85%', 'scale': 0.85},
    {'label': 'Default', 'sublabel': '100%', 'scale': 1.0},
    {'label': 'Large', 'sublabel': '115%', 'scale': 1.15},
    {'label': 'Extra', 'sublabel': '130%', 'scale': 1.30},
  ];
}

final speedFontScaleProvider =
    StateNotifierProvider<SpeedFontScaleNotifier, double>((ref) {
  return SpeedFontScaleNotifier();
});

class SpeedFontScaleNotifier extends StateNotifier<double> {
  static const String _prefKey = 'speed_display_font_scale';
  Timer? _saveDebounceTimer;

  SpeedFontScaleNotifier() : super(SpeedFontScaleConfig.defaultScale) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedScale = prefs.getDouble(_prefKey);
      if (savedScale != null) {
        state = savedScale.clamp(
          SpeedFontScaleConfig.minScale,
          SpeedFontScaleConfig.maxScale,
        );
      }
    } catch (e) {
      debugPrint('Error loading speed font scale from prefs: $e');
    }
  }

  void _debounceSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 200), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_prefKey, state);
      } catch (e) {
        debugPrint('Error persisting speed font scale: $e');
      }
    });
  }

  void setScale(double scale) {
    final clamped = (scale.clamp(
      SpeedFontScaleConfig.minScale,
      SpeedFontScaleConfig.maxScale,
    ) * 100).round() / 100.0;
    if (state == clamped) return;
    state = clamped;
    _debounceSave();
  }

  void increase() {
    final next = (state + SpeedFontScaleConfig.step * 100).round() / 100.0;
    setScale(next);
  }

  void decrease() {
    final next = (state - SpeedFontScaleConfig.step * 100).round() / 100.0;
    setScale(next);
  }

  void reset() {
    setScale(SpeedFontScaleConfig.defaultScale);
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}
