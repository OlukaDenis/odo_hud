import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/unit_converter.dart';

class LocationUpdate {
  final double speedKmh;
  final double distanceDeltaMeters;
  final double headingDegrees;
  final double accuracyMeters;
  final bool isGpsLocked;
  final DateTime timestamp;

  const LocationUpdate({
    required this.speedKmh,
    required this.distanceDeltaMeters,
    required this.headingDegrees,
    required this.accuracyMeters,
    required this.isGpsLocked,
    required this.timestamp,
  });
}

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  Position? _lastValidPosition;

  Stream<LocationUpdate> getPositionStream() {
    late final LocationSettings locationSettings;

    if (!kIsWeb && Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: null, // Managed via FlutterForegroundTask
      );
    } else if (!kIsWeb && Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 1,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) {
        final accuracy = position.accuracy;
        final rawSpeedMps = position.speed;
        final rawHeading = position.heading;

        // GPS Lock condition: accuracy must be within acceptable boundary (<= 20m)
        final isGpsLocked = accuracy <= AppConstants.maxAcceptableGpsAccuracyMeters && accuracy > 0;

        // Stationary Noise Gate:
        // If speed < 0.42 m/s (1.5 km/h) or GPS accuracy > 20m, clamp speed to 0.0
        double speedKmh = 0.0;
        double distanceDeltaMeters = 0.0;

        if (isGpsLocked && rawSpeedMps >= AppConstants.minMovingSpeedMps) {
          speedKmh = UnitConverter.mpsToKmh(rawSpeedMps);

          // Calculate distance delta using Haversine
          if (_lastValidPosition != null) {
            final distance = Geolocator.distanceBetween(
              _lastValidPosition!.latitude,
              _lastValidPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            // Filter out unreasonable GPS teleports (> 150 m in 1 second = > 540 km/h)
            if (distance < 150.0) {
              distanceDeltaMeters = distance;
            }
          }
          _lastValidPosition = position;
        } else if (isGpsLocked) {
          // Stationary position fix
          _lastValidPosition = position;
        }

        return LocationUpdate(
          speedKmh: speedKmh,
          distanceDeltaMeters: distanceDeltaMeters,
          headingDegrees: rawHeading >= 0 ? rawHeading : 0.0,
          accuracyMeters: accuracy,
          isGpsLocked: isGpsLocked,
          timestamp: position.timestamp,
        );
      },
    );
  }

  void resetLastPosition() {
    _lastValidPosition = null;
  }
}
