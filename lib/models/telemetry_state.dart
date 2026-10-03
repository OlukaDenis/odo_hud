class TelemetryState {
  final double currentSpeedKmh;
  final double currentSpeedMph;
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

  const TelemetryState({
    this.currentSpeedKmh = 0.0,
    this.currentSpeedMph = 0.0,
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
  });

  TelemetryState copyWith({
    double? currentSpeedKmh,
    double? currentSpeedMph,
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
  }) {
    return TelemetryState(
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      currentSpeedMph: currentSpeedMph ?? this.currentSpeedMph,
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
    );
  }
}
