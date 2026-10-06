import 'dart:math' as math;

/// Configuration for vehicle speedometer calibration offset and tire size compensation.
///
/// Under international automotive regulations (UNECE Regulation 39), factory speedometers
/// are legally prohibited from underreporting speed and typically read 5%–10% higher than
/// true GPS velocity. Additionally, aftermarket wheel/tire circumferences alter dashboard readouts.
class SpeedCalibrationConfig {
  /// Whether calibration offset is active. When false, pure GPS velocity is used.
  final bool isEnabled;

  /// Proportional percentage adjustment (e.g. +5.0 means +5%).
  /// Typically 5%–10% for factory speedometers or ±3%–15% for tire sizing deltas.
  final double percentageOffset;

  /// Fixed speed offset in km/h (e.g. +3.0 km/h).
  final double fixedOffsetKmh;

  const SpeedCalibrationConfig({
    this.isEnabled = false,
    this.percentageOffset = 0.0,
    this.fixedOffsetKmh = 0.0,
  });

  /// Factory True GPS velocity (0% offset, pure satellite ground speed)
  static const SpeedCalibrationConfig gpsTrue = SpeedCalibrationConfig(
    isEnabled: false,
    percentageOffset: 0.0,
    fixedOffsetKmh: 0.0,
  );

  /// Standard European/Japanese factory offset (+5% proportional)
  static const SpeedCalibrationConfig factoryPlus5 = SpeedCalibrationConfig(
    isEnabled: true,
    percentageOffset: 5.0,
    fixedOffsetKmh: 0.0,
  );

  /// High factory safety buffer (+8% proportional)
  static const SpeedCalibrationConfig factoryPlus8 = SpeedCalibrationConfig(
    isEnabled: true,
    percentageOffset: 8.0,
    fixedOffsetKmh: 0.0,
  );

  /// UNECE Regulation 39 European standard (+7% + 2 km/h)
  static const SpeedCalibrationConfig uneceReg39 = SpeedCalibrationConfig(
    isEnabled: true,
    percentageOffset: 7.0,
    fixedOffsetKmh: 2.0,
  );

  /// Applies the calibration formula to raw GPS velocity in km/h.
  ///
  /// CRITICAL SAFETY RULE:
  /// When vehicle is stationary ([rawSpeedKmh] <= 0.001), calibrated speed is always clamped
  /// to 0.0 km/h so vehicles standing at red lights/intersections never display phantom velocity.
  double apply(double rawSpeedKmh) {
    if (!isEnabled) {
      return rawSpeedKmh;
    }
    if (rawSpeedKmh <= 0.001) {
      return 0.0;
    }

    final scaled = rawSpeedKmh * (1.0 + (percentageOffset / 100.0));
    final withFixed = scaled + fixedOffsetKmh;
    return math.max(0.0, withFixed);
  }

  /// Human-readable summary badge (e.g. "OFF", "+5%", "+7% + 2 km/h")
  String get summaryText {
    if (!isEnabled || (percentageOffset == 0.0 && fixedOffsetKmh == 0.0)) {
      return 'OFF (True GPS)';
    }

    final buffer = StringBuffer();
    if (percentageOffset != 0.0) {
      final sign = percentageOffset > 0 ? '+' : '';
      buffer.write('$sign${percentageOffset.toStringAsFixed(0)}%');
    }

    if (fixedOffsetKmh != 0.0) {
      final sign = fixedOffsetKmh > 0 ? '+' : '';
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write('$sign${fixedOffsetKmh.toStringAsFixed(0)} km/h');
    }

    return buffer.isEmpty ? 'OFF' : buffer.toString();
  }

  SpeedCalibrationConfig copyWith({
    bool? isEnabled,
    double? percentageOffset,
    double? fixedOffsetKmh,
  }) {
    return SpeedCalibrationConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      percentageOffset: percentageOffset ?? this.percentageOffset,
      fixedOffsetKmh: fixedOffsetKmh ?? this.fixedOffsetKmh,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeedCalibrationConfig &&
          runtimeType == other.runtimeType &&
          isEnabled == other.isEnabled &&
          percentageOffset == other.percentageOffset &&
          fixedOffsetKmh == other.fixedOffsetKmh;

  @override
  int get hashCode =>
      isEnabled.hashCode ^
      percentageOffset.hashCode ^
      fixedOffsetKmh.hashCode;
}
