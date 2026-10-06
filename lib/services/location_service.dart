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
        intervalDuration: const Duration(milliseconds: 250),
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
        final isGpsLocked = accuracy <= AppConstants.maxAcceptableGpsAccuracyMeters && accuracy > 0;

        double speedKmh = 0.0;
        double distanceDeltaMeters = 0.0;

        if (isGpsLocked) {
          double effectiveSpeedMps = rawSpeedMps;

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

            // Maximum realistic GPS jump threshold based on elapsed time (up to 150m/sec)
            final maxPlausibleDistance = elapsedMs > 0
                ? (150.0 * (elapsedMs / 1000.0)).clamp(5.0, 150.0)
                : 150.0;

            if (distance < maxPlausibleDistance) {
              distanceDeltaMeters = distance;

              // Takeoff / Acceleration Assist:
              // If Doppler speed is lagging (< min threshold) during rapid vehicle takeoff,
              // use time-differentiated distance delta to eliminate initial hesitation
              if (effectiveSpeedMps < AppConstants.minMovingSpeedMps && elapsedMs >= 200) {
                final calculatedSpeedMps = distance / (elapsedMs / 1000.0);
                if (calculatedSpeedMps >= AppConstants.minMovingSpeedMps && calculatedSpeedMps < 70.0) {
                  effectiveSpeedMps = calculatedSpeedMps;
                }
              }
            }
          }

          // Stationary Noise Gate: clamp to 0 if below min moving speed
          if (effectiveSpeedMps >= AppConstants.minMovingSpeedMps) {
            speedKmh = UnitConverter.mpsToKmh(effectiveSpeedMps);
          }

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
