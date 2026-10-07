import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

class SensorService {
  static final SensorService instance = SensorService._();
  SensorService._();

  final Battery _battery = Battery();

  Stream<int> get batteryLevelStream async* {
    try {
      final initialLevel = await _battery.batteryLevel;
      yield initialLevel;
    } catch (e) {
      debugPrint('Error getting initial battery level: $e');
      yield 100;
    }

    // Periodic check every 30 seconds for battery level update
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      try {
        final level = await _battery.batteryLevel;
        yield level;
      } catch (e) {
        debugPrint('Error polling battery level: $e');
      }
    }
  }

  Stream<double> get compassHeadingStream {
    if (kIsWeb) {
      return Stream.value(0.0);
    }

    double? lastHeading;

    return FlutterCompass.events
            ?.where((event) => event.heading != null)
            .map((event) {
              // Normalize angle to [0, 360) to correctly handle negative readings
              final raw = (event.heading! % 360.0 + 360.0) % 360.0;

              if (lastHeading == null) {
                lastHeading = raw;
                return raw;
              }

              // Compute shortest angular delta across the 0°/360° boundary
              final delta = ((raw - lastHeading! + 540.0) % 360.0) - 180.0;

              // Sensor noise deadband: suppress microscopic sensor jitter (< 0.8°)
              if (delta.abs() < 0.8) {
                return lastHeading!;
              }

              // Dynamic Exponential Moving Average (EMA) smoothing:
              // Fast tracking for deliberate turns, smooth damping for stability
              final alpha = delta.abs() > 15.0 ? 0.55 : 0.25;
              final smoothed = (lastHeading! + delta * alpha + 360.0) % 360.0;
              lastHeading = smoothed;
              return smoothed;
            })
            .distinct((prev, next) => (prev - next).abs() < 0.3)
            .handleError((e) {
              debugPrint('Compass error: $e');
              return 0.0;
            }) ??
        Stream.value(0.0);
  }
}
