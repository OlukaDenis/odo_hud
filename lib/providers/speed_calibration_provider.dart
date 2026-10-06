import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/speed_calibration_config.dart';

final speedCalibrationProvider =
    StateNotifierProvider<SpeedCalibrationNotifier, SpeedCalibrationConfig>((ref) {
  return SpeedCalibrationNotifier();
});

class SpeedCalibrationNotifier extends StateNotifier<SpeedCalibrationConfig> {
  static const _keyEnabled = 'speed_calib_enabled';
  static const _keyPercent = 'speed_calib_percent';
  static const _keyFixedKmh = 'speed_calib_fixed_kmh';

  Timer? _saveDebounceTimer;

  SpeedCalibrationNotifier() : super(SpeedCalibrationConfig.gpsTrue) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_keyEnabled) ?? false;
      final percent = prefs.getDouble(_keyPercent) ?? 0.0;
      final fixedKmh = prefs.getDouble(_keyFixedKmh) ?? 0.0;

      state = SpeedCalibrationConfig(
        isEnabled: enabled,
        percentageOffset: percent,
        fixedOffsetKmh: fixedKmh,
      );
    } catch (e) {
      debugPrint('Error loading speed calibration prefs: $e');
    }
  }

  void _debounceSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 200), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyEnabled, state.isEnabled);
        await prefs.setDouble(_keyPercent, state.percentageOffset);
        await prefs.setDouble(_keyFixedKmh, state.fixedOffsetKmh);
      } catch (e) {
        debugPrint('Error persisting speed calibration: $e');
      }
    });
  }

  void setEnabled(bool isEnabled) {
    state = state.copyWith(isEnabled: isEnabled);
    _debounceSave();
  }

  void toggleEnabled() {
    setEnabled(!state.isEnabled);
  }

  void setPercentageOffset(double percent) {
    state = state.copyWith(percentageOffset: percent);
    _debounceSave();
  }

  void setFixedOffsetKmh(double fixedKmh) {
    state = state.copyWith(fixedOffsetKmh: fixedKmh);
    _debounceSave();
  }

  void setCalibration({
    bool? isEnabled,
    double? percentageOffset,
    double? fixedOffsetKmh,
  }) {
    state = state.copyWith(
      isEnabled: isEnabled,
      percentageOffset: percentageOffset,
      fixedOffsetKmh: fixedOffsetKmh,
    );
    _debounceSave();
  }

  void applyPreset(SpeedCalibrationConfig preset) {
    state = preset;
    _debounceSave();
  }

  void resetToGpsTrue() {
    state = SpeedCalibrationConfig.gpsTrue;
    _debounceSave();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}
