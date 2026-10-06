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
        distanceFilter: 0,
        intervalDuration: const Duration(milliseconds: 500),
        foregroundNotificationConfig: null, // Managed via FlutterForegroundTask
      );
    } else if (!kIsWeb && Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) {
        final accuracy = position.accuracy;
        final rawSpeedMps = position.speed;
        final rawHeading = position.heading;

        // GPS Lock condition: accuracy must be within acceptable boundary (<= 20m)
        final isGpsLocked =
            accuracy <= AppConstants.maxAcceptableGpsAccuracyMeters && accuracy > 0;

        double speedKmh = 0.0;
        double distanceDeltaMeters = 0.0;

        // Authoritative GNSS Hardware Doppler speed:
        // Hardware Doppler measures radio carrier wave frequency shift, which is
        // strictly 0.0 when stationary and completely immune to coordinate drift/noise.
        if (isGpsLocked && rawSpeedMps >= AppConstants.minMovingSpeedMps) {
          speedKmh = UnitConverter.mpsToKmh(rawSpeedMps);

          if (_lastValidPosition != null) {
            final distance = Geolocator.distanceBetween(
              _lastValidPosition!.latitude,
              _lastValidPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            final elapsedMs = position.timestamp
                .difference(_lastValidPosition!.timestamp)
                .inMilliseconds;

            // Maximum realistic GPS jump threshold based on elapsed time (up to 150m/sec = 540 km/h)
            final maxPlausibleDistance = elapsedMs > 0
                ? (150.0 * (elapsedMs / 1000.0)).clamp(5.0, 150.0)
                : 150.0;

            if (distance < maxPlausibleDistance) {
              distanceDeltaMeters = distance;
            }
          }

          _lastValidPosition = position;
        } else if (isGpsLocked) {
          // Stationary position fix (stopped at a red light or resting on a table):
          // Maintain position fix without accumulating phantom distance
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
