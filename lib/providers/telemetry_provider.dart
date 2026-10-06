import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/unit_converter.dart';
import '../data/database/isar_service.dart';
import '../data/models/telemetry_record.dart';
import '../data/models/trip_record.dart';
import '../models/speed_calibration_config.dart';
import '../models/telemetry_state.dart';
import '../services/foreground_service.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import 'speed_calibration_provider.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

final telemetryProvider =
    StateNotifierProvider<TelemetryNotifier, TelemetryState>((ref) {
  final isar = ref.watch(isarServiceProvider);
  final notifier = TelemetryNotifier(isar);

  final initialCalib = ref.read(speedCalibrationProvider);
  notifier.updateCalibration(initialCalib);

  ref.listen<SpeedCalibrationConfig>(speedCalibrationProvider, (prev, next) {
    notifier.updateCalibration(next);
  });

  return notifier;
});

class TelemetryNotifier extends StateNotifier<TelemetryState> {
  final IsarService _isar;

  StreamSubscription<LocationUpdate>? _locationSubscription;
  StreamSubscription<int>? _batterySubscription;
  StreamSubscription<double>? _compassSubscription;

  Timer? _persistenceTimer;
  Timer? _movingSecondTimer;
  Timer? _watchdogTimer;

  DateTime? _lastGpsTimestamp;
  double _lifetimeOdometerMeters = 0.0;
  double _activeTripMeters = 0.0;
  int _activeTripMovingSeconds = 0;
  double _maxSpeedKmh = 0.0;
  bool _isMoving = false;

  // Active Trip Recording Session
  DateTime? _recordingStartTime;
  double _recordedTripMeters = 0.0;
  int _recordedTripSeconds = 0; // Elapsed total seconds
  int _recordedTripMovingSeconds = 0; // Active moving seconds
  int _recordedTripPauseSeconds = 0; // Paused / idle seconds
  double _recordedTripMaxSpeedKmh = 0.0;
  final List<TripEvent> _tripEvents = [];

  SpeedCalibrationConfig _calibration = SpeedCalibrationConfig.gpsTrue;

  TelemetryNotifier(this._isar) : super(const TelemetryState()) {
    _initialize();
  }

  void updateCalibration(SpeedCalibrationConfig config) {
    _calibration = config;
    final displayKmh = _calibration.apply(state.currentSpeedKmh);
    final displayMph = UnitConverter.kmhToMph(displayKmh);
    state = state.copyWith(
      displaySpeedKmh: displayKmh,
      displaySpeedMph: displayMph,
    );
    _updateForegroundNotification();
  }

  Future<void> _initialize() async {
    // 1. Load persisted totals from Isar
    final record = await _isar.getTelemetryRecord();
    _lifetimeOdometerMeters = record.lifetimeOdometerMeters;
    _activeTripMeters = record.activeTripMeters;
    _activeTripMovingSeconds = record.activeTripMovingSeconds;
    _maxSpeedKmh = record.maxSpeedKmh;

    final tripKm = UnitConverter.metersToKm(_activeTripMeters);
    final odoKm = UnitConverter.metersToKm(_lifetimeOdometerMeters);
    final avgSpeedKmh = _activeTripMovingSeconds > 0
        ? tripKm / (_activeTripMovingSeconds / 3600.0)
        : 0.0;

    state = state.copyWith(
      tripDistanceKm: tripKm,
      tripDistanceMiles: UnitConverter.kmToMiles(tripKm),
      odometerKm: odoKm,
      movingTimeSeconds: _activeTripMovingSeconds,
      averageSpeedKmh: avgSpeedKmh,
      maxSpeedKmh: _maxSpeedKmh,
    );

    // 2. Start Foreground Service
    await ForegroundServiceManager.instance.startService();

    // 3. Subscribe to Sensors
    _subscribeSensors();

    // 4. Subscribe to GPS
    _subscribeLocation();

    // 5. Start Moving Second Timer (increments moving time when speed > 1.5 km/h)
    _movingSecondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRecordingTrip) {
        if (!state.isTripPaused) {
          _recordedTripSeconds++;
          if (_isMoving) {
            _activeTripMovingSeconds++;
            _recordedTripMovingSeconds++;
          }
          final curTripKm = UnitConverter.metersToKm(_recordedTripMeters);
          final curAvgSpeed = _recordedTripMovingSeconds > 0
              ? curTripKm / (_recordedTripMovingSeconds / 3600.0)
              : 0.0;

          state = state.copyWith(
            movingTimeSeconds: _activeTripMovingSeconds,
            recordedTripSeconds: _recordedTripSeconds,
            averageSpeedKmh: curAvgSpeed,
          );
        } else {
          _recordedTripPauseSeconds++;
        }
      } else {
        if (_isMoving) {
          _activeTripMovingSeconds++;
          final curTripKm = UnitConverter.metersToKm(_activeTripMeters);
          final curAvgSpeed = _activeTripMovingSeconds > 0
              ? curTripKm / (_activeTripMovingSeconds / 3600.0)
              : 0.0;

          state = state.copyWith(
            movingTimeSeconds: _activeTripMovingSeconds,
            averageSpeedKmh: curAvgSpeed,
          );
        }
      }
    });

    // 6. Start 5-second persistence flush loop & notification update
    _persistenceTimer =
        Timer.periodic(AppConstants.persistenceFlushInterval, (_) {
      _flushToDatabase();
      _updateForegroundNotification();
    });

    // 7. Watchdog timer for GPS signal loss (> 3s without GPS update)
    _watchdogTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastGpsTimestamp != null) {
        final elapsed = DateTime.now().difference(_lastGpsTimestamp!).inSeconds;
        if (elapsed > AppConstants.gpsTimeoutSeconds && state.isGpsLocked) {
          state = state.copyWith(
            isGpsLocked: false,
            currentSpeedKmh: 0.0,
            currentSpeedMph: 0.0,
            displaySpeedKmh: 0.0,
            displaySpeedMph: 0.0,
          );
          _isMoving = false;
        }
      }
    });
  }

  void _subscribeLocation() {
    _locationSubscription =
        LocationService.instance.getPositionStream().listen(
      (update) {
        _lastGpsTimestamp = DateTime.now();

        final speedKmh = update.speedKmh;
        final speedMph = UnitConverter.kmhToMph(speedKmh);
        final displayKmh = _calibration.apply(speedKmh);
        final displayMph = UnitConverter.kmhToMph(displayKmh);

        _isMoving = speedKmh >= AppConstants.minMovingSpeedKmh;

        if (_isMoving) {
          _lifetimeOdometerMeters += update.distanceDeltaMeters;

          if (state.isRecordingTrip) {
            if (!state.isTripPaused) {
              _recordedTripMeters += update.distanceDeltaMeters;
              _activeTripMeters = _recordedTripMeters;
              if (speedKmh > _maxSpeedKmh) {
                _maxSpeedKmh = speedKmh;
              }
              if (speedKmh > _recordedTripMaxSpeedKmh) {
                _recordedTripMaxSpeedKmh = speedKmh;
              }
            }
          } else {
            _activeTripMeters += update.distanceDeltaMeters;
            if (speedKmh > _maxSpeedKmh) {
              _maxSpeedKmh = speedKmh;
            }
          }
        }

        final tripKm = UnitConverter.metersToKm(_activeTripMeters);
        final tripMiles = UnitConverter.kmToMiles(tripKm);
        final odoKm = UnitConverter.metersToKm(_lifetimeOdometerMeters);

        final activeMovingSecs = state.isRecordingTrip
            ? _recordedTripMovingSeconds
            : _activeTripMovingSeconds;
        final avgSpeedKmh = activeMovingSecs > 0
            ? tripKm / (activeMovingSecs / 3600.0)
            : 0.0;

        final cardinal = UnitConverter.degreesToCardinal(update.headingDegrees);

        state = state.copyWith(
          currentSpeedKmh: speedKmh,
          currentSpeedMph: speedMph,
          displaySpeedKmh: displayKmh,
          displaySpeedMph: displayMph,
          tripDistanceKm: tripKm,
          tripDistanceMiles: tripMiles,
          odometerKm: odoKm,
          averageSpeedKmh: avgSpeedKmh,
          maxSpeedKmh: _maxSpeedKmh,
          headingDegrees: update.headingDegrees,
          cardinalDirection: cardinal,
          gpsAccuracyMeters: update.accuracyMeters,
          isGpsLocked: update.isGpsLocked,
          recordedTripDistanceKm: UnitConverter.metersToKm(_recordedTripMeters),
          recordedTripMaxSpeedKmh: _recordedTripMaxSpeedKmh,
          altitudeMeters: update.altitudeMeters,
          latitude: update.latitude,
          longitude: update.longitude,
        );
      },
      onError: (e) {
        state = state.copyWith(isGpsLocked: false);
      },
    );
  }

  void _subscribeSensors() {
    _batterySubscription =
        SensorService.instance.batteryLevelStream.listen((percent) {
      state = state.copyWith(batteryPercent: percent);
    });

    _compassSubscription =
        SensorService.instance.compassHeadingStream.listen((heading) {
      // Use compass heading if GPS is stationary or stationary heading is not updated
      if (!_isMoving && heading >= 0) {
        state = state.copyWith(
          headingDegrees: heading,
          cardinalDirection: UnitConverter.degreesToCardinal(heading),
        );
      }
    });
  }

  Future<void> _flushToDatabase() async {
    final record = TelemetryRecord()
      ..lifetimeOdometerMeters = _lifetimeOdometerMeters
      ..activeTripMeters = _activeTripMeters
      ..activeTripMovingSeconds = _activeTripMovingSeconds
      ..maxSpeedKmh = _maxSpeedKmh;
    await _isar.saveTelemetryRecord(record);
  }

  void _updateForegroundNotification() {
    ForegroundServiceManager.instance.updateNotification(
      speedKmh: state.displaySpeedKmh,
      tripKm: state.tripDistanceKm,
      timeFormatted: UnitConverter.formatMovingTime(state.movingTimeSeconds),
      isMetric: true,
    );
  }

  void toggleHudMirror() {
    state = state.copyWith(isHudMirrored: !state.isHudMirrored);
  }

  Future<void> startTripRecording() async {
    _recordingStartTime = DateTime.now();
    _recordedTripMeters = 0.0;
    _recordedTripSeconds = 0;
    _recordedTripMovingSeconds = 0;
    _recordedTripPauseSeconds = 0;
    _recordedTripMaxSpeedKmh = state.currentSpeedKmh;

    // Reset dashboard active trip counts so they cleanly mirror the recorded ride
    _activeTripMeters = 0.0;
    _activeTripMovingSeconds = 0;
    _maxSpeedKmh = state.currentSpeedKmh;

    _tripEvents.clear();
    _tripEvents.add(
      TripEvent(
        type: 'start',
        timestamp: _recordingStartTime!,
        distanceKm: 0.0,
        speedKmh: state.currentSpeedKmh,
      ),
    );

    LocationService.instance.resetLastPosition();
    await _isar.resetTrip();

    state = state.copyWith(
      isRecordingTrip: true,
      isTripPaused: false,
      recordingStartTime: _recordingStartTime,
      tripDistanceKm: 0.0,
      tripDistanceMiles: 0.0,
      movingTimeSeconds: 0,
      averageSpeedKmh: 0.0,
      maxSpeedKmh: _maxSpeedKmh,
      recordedTripDistanceKm: 0.0,
      recordedTripSeconds: 0,
      recordedTripMaxSpeedKmh: _recordedTripMaxSpeedKmh,
    );
  }

  void togglePauseTripRecording() {
    if (!state.isRecordingTrip) return;
    final willBePaused = !state.isTripPaused;
    final now = DateTime.now();
    final currentDistKm = UnitConverter.metersToKm(_recordedTripMeters);

    _tripEvents.add(
      TripEvent(
        type: willBePaused ? 'pause' : 'resume',
        timestamp: now,
        distanceKm: currentDistKm,
        speedKmh: state.currentSpeedKmh,
      ),
    );

    state = state.copyWith(isTripPaused: willBePaused);
  }

  Future<TripRecord?> stopTripRecording() async {
    if (!state.isRecordingTrip) return null;

    final start = _recordingStartTime ?? DateTime.now();
    final end = DateTime.now();
    final distanceKm = UnitConverter.metersToKm(_recordedTripMeters);
    final durationSec = _recordedTripSeconds > 0
        ? _recordedTripSeconds
        : end.difference(start).inSeconds;
    final movingSec = _recordedTripMovingSeconds;
    final pauseSec = _recordedTripPauseSeconds;
    final topSpeed = _recordedTripMaxSpeedKmh;
    final avgSpeed = movingSec > 0
        ? distanceKm / (movingSec / 3600.0)
        : (durationSec > 0 ? distanceKm / (durationSec / 3600.0) : 0.0);

    _tripEvents.add(
      TripEvent(
        type: 'stop',
        timestamp: end,
        distanceKm: distanceKm,
        speedKmh: state.currentSpeedKmh,
      ),
    );

    final trip = TripRecord()
      ..startTime = start
      ..endTime = end
      ..distanceKm = distanceKm
      ..durationSeconds = durationSec
      ..movingDurationSeconds = movingSec
      ..pauseDurationSeconds = pauseSec
      ..topSpeedKmh = topSpeed
      ..avgSpeedKmh = avgSpeed
      ..title = _generateHumanTripTitle(start)
      ..isCompleted = true;
    trip.events = List.from(_tripEvents);

    await _isar.saveTrip(trip);

    // Reset all dashboard counts back to 0.0 ready for the next ride
    _activeTripMeters = 0.0;
    _activeTripMovingSeconds = 0;
    _maxSpeedKmh = 0.0;
    _recordedTripMeters = 0.0;
    _recordedTripSeconds = 0;
    _recordedTripMovingSeconds = 0;
    _recordedTripPauseSeconds = 0;
    _recordingStartTime = null;
    _tripEvents.clear();
    LocationService.instance.resetLastPosition();
    await _isar.resetTrip();

    state = state.copyWith(
      isRecordingTrip: false,
      isTripPaused: false,
      recordingStartTime: null,
      tripDistanceKm: 0.0,
      tripDistanceMiles: 0.0,
      movingTimeSeconds: 0,
      averageSpeedKmh: 0.0,
      maxSpeedKmh: 0.0,
      recordedTripDistanceKm: 0.0,
      recordedTripSeconds: 0,
      recordedTripMaxSpeedKmh: 0.0,
    );

    return trip;
  }

  Future<void> discardActiveTripRecording() async {
    _recordingStartTime = null;
    _recordedTripMeters = 0.0;
    _recordedTripSeconds = 0;
    _recordedTripMovingSeconds = 0;
    _recordedTripPauseSeconds = 0;
    _recordedTripMaxSpeedKmh = 0.0;
    _tripEvents.clear();

    _activeTripMeters = 0.0;
    _activeTripMovingSeconds = 0;
    _maxSpeedKmh = 0.0;
    LocationService.instance.resetLastPosition();
    await _isar.resetTrip();

    state = state.copyWith(
      isRecordingTrip: false,
      isTripPaused: false,
      recordingStartTime: null,
      tripDistanceKm: 0.0,
      tripDistanceMiles: 0.0,
      movingTimeSeconds: 0,
      averageSpeedKmh: 0.0,
      maxSpeedKmh: 0.0,
      recordedTripDistanceKm: 0.0,
      recordedTripSeconds: 0,
      recordedTripMaxSpeedKmh: 0.0,
    );
  }

  String _generateHumanTripTitle(DateTime dt) {
    final hour = dt.hour;
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final day = weekdays[dt.weekday - 1];

    if (hour >= 5 && hour < 12) {
      return '$day Morning Ride';
    } else if (hour >= 12 && hour < 17) {
      return '$day Afternoon Ride';
    } else if (hour >= 17 && hour < 21) {
      return '$day Evening Cruise';
    } else {
      return '$day Night Ride';
    }
  }

  Future<void> resetTrip() async {
    if (state.isRecordingTrip) {
      await discardActiveTripRecording();
      return;
    }

    _activeTripMeters = 0.0;
    _activeTripMovingSeconds = 0;
    _maxSpeedKmh = 0.0;
    LocationService.instance.resetLastPosition();

    await _isar.resetTrip();

    state = state.copyWith(
      tripDistanceKm: 0.0,
      tripDistanceMiles: 0.0,
      movingTimeSeconds: 0,
      averageSpeedKmh: 0.0,
      maxSpeedKmh: 0.0,
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _batterySubscription?.cancel();
    _compassSubscription?.cancel();
    _persistenceTimer?.cancel();
    _movingSecondTimer?.cancel();
    _watchdogTimer?.cancel();
    _flushToDatabase();
    ForegroundServiceManager.instance.stopService();
    super.dispose();
  }
}
