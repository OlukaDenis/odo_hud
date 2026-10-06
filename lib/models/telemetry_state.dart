class TelemetryState {
  final double currentSpeedKmh;
  final double currentSpeedMph;
  final double displaySpeedKmh;
  final double displaySpeedMph;
  final double tripDistanceKm;
  final double tripDistanceMiles;
  final double odometerKm;
  final int movingTimeSeconds;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final double headingDegrees;
  final String cardinalDirection;
  final double gpsAccuracyMeters;
  final bool isGpsLocked;
  final bool isHudMirrored;
  final int batteryPercent;
  final bool isRecordingTrip;
  final bool isTripPaused;
  final DateTime? recordingStartTime;
  final double recordedTripDistanceKm;
  final int recordedTripSeconds;
  final double recordedTripMaxSpeedKmh;
  final double altitudeMeters;
  final double latitude;
  final double longitude;

  const TelemetryState({
    this.currentSpeedKmh = 0.0,
    this.currentSpeedMph = 0.0,
    this.displaySpeedKmh = 0.0,
    this.displaySpeedMph = 0.0,
    this.tripDistanceKm = 0.0,
    this.tripDistanceMiles = 0.0,
    this.odometerKm = 0.0,
    this.movingTimeSeconds = 0,
    this.averageSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.headingDegrees = 0.0,
    this.cardinalDirection = 'N',
    this.gpsAccuracyMeters = 999.0,
    this.isGpsLocked = false,
    this.isHudMirrored = false,
    this.batteryPercent = 100,
    this.isRecordingTrip = false,
    this.isTripPaused = false,
    this.recordingStartTime,
    this.recordedTripDistanceKm = 0.0,
    this.recordedTripSeconds = 0,
    this.recordedTripMaxSpeedKmh = 0.0,
    this.altitudeMeters = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  TelemetryState copyWith({
    double? currentSpeedKmh,
    double? currentSpeedMph,
    double? displaySpeedKmh,
    double? displaySpeedMph,
    double? tripDistanceKm,
    double? tripDistanceMiles,
    double? odometerKm,
    int? movingTimeSeconds,
    double? averageSpeedKmh,
    double? maxSpeedKmh,
    double? headingDegrees,
    String? cardinalDirection,
    double? gpsAccuracyMeters,
    bool? isGpsLocked,
    bool? isHudMirrored,
    int? batteryPercent,
    bool? isRecordingTrip,
    bool? isTripPaused,
    DateTime? recordingStartTime,
    double? recordedTripDistanceKm,
    int? recordedTripSeconds,
    double? recordedTripMaxSpeedKmh,
    double? altitudeMeters,
    double? latitude,
    double? longitude,
  }) {
    return TelemetryState(
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      currentSpeedMph: currentSpeedMph ?? this.currentSpeedMph,
      displaySpeedKmh: displaySpeedKmh ?? this.displaySpeedKmh,
      displaySpeedMph: displaySpeedMph ?? this.displaySpeedMph,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      tripDistanceMiles: tripDistanceMiles ?? this.tripDistanceMiles,
      odometerKm: odometerKm ?? this.odometerKm,
      movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      cardinalDirection: cardinalDirection ?? this.cardinalDirection,
      gpsAccuracyMeters: gpsAccuracyMeters ?? this.gpsAccuracyMeters,
      isGpsLocked: isGpsLocked ?? this.isGpsLocked,
      isHudMirrored: isHudMirrored ?? this.isHudMirrored,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      isRecordingTrip: isRecordingTrip ?? this.isRecordingTrip,
      isTripPaused: isTripPaused ?? this.isTripPaused,
      recordingStartTime: recordingStartTime ?? this.recordingStartTime,
      recordedTripDistanceKm:
          recordedTripDistanceKm ?? this.recordedTripDistanceKm,
      recordedTripSeconds: recordedTripSeconds ?? this.recordedTripSeconds,
      recordedTripMaxSpeedKmh:
          recordedTripMaxSpeedKmh ?? this.recordedTripMaxSpeedKmh,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
