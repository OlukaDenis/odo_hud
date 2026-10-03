import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/unit_converter.dart';
import '../data/database/isar_service.dart';
import '../data/models/telemetry_record.dart';
import '../models/telemetry_state.dart';
import '../services/foreground_service.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

final telemetryProvider =
    StateNotifierProvider<TelemetryNotifier, TelemetryState>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return TelemetryNotifier(isar);
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

  TelemetryNotifier(this._isar) : super(const TelemetryState()) {
    _initialize();
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

        _isMoving = speedKmh >= AppConstants.minMovingSpeedKmh;

        if (_isMoving) {
          _activeTripMeters += update.distanceDeltaMeters;
          _lifetimeOdometerMeters += update.distanceDeltaMeters;

          if (speedKmh > _maxSpeedKmh) {
            _maxSpeedKmh = speedKmh;
          }
        }

        final tripKm = UnitConverter.metersToKm(_activeTripMeters);
        final tripMiles = UnitConverter.kmToMiles(tripKm);
        final odoKm = UnitConverter.metersToKm(_lifetimeOdometerMeters);

        final avgSpeedKmh = _activeTripMovingSeconds > 0
            ? tripKm / (_activeTripMovingSeconds / 3600.0)
            : 0.0;

        final cardinal = UnitConverter.degreesToCardinal(update.headingDegrees);

        state = state.copyWith(
          currentSpeedKmh: speedKmh,
          currentSpeedMph: speedMph,
          tripDistanceKm: tripKm,
          tripDistanceMiles: tripMiles,
          odometerKm: odoKm,
          averageSpeedKmh: avgSpeedKmh,
          maxSpeedKmh: _maxSpeedKmh,
          headingDegrees: update.headingDegrees,
          cardinalDirection: cardinal,
          gpsAccuracyMeters: update.accuracyMeters,
          isGpsLocked: update.isGpsLocked,
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
      speedKmh: state.currentSpeedKmh,
      tripKm: state.tripDistanceKm,
      timeFormatted: UnitConverter.formatMovingTime(state.movingTimeSeconds),
      isMetric: true,
    );
  }

  void toggleHudMirror() {
    state = state.copyWith(isHudMirrored: !state.isHudMirrored);
  }

  Future<void> resetTrip() async {
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
