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
    return FlutterCompass.events
            ?.map((event) => event.heading ?? 0.0)
            .handleError((e) {
          debugPrint('Compass error: $e');
          return 0.0;
        }) ??
        Stream.value(0.0);
  }
}
