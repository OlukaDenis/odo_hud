class AppConstants {
  AppConstants._();

  // GPS & Telemetry Constants
  static const double minMovingSpeedMps = 0.222222; // 0.8 km/h in m/s (enables instant takeoff detection)
  static const double minMovingSpeedKmh = 0.8;
  static const double maxAcceptableGpsAccuracyMeters = 20.0;
  static const int gpsTimeoutSeconds = 3;
  static const Duration persistenceFlushInterval = Duration(seconds: 5);

  // Conversion Factors
  static const double kmToMiles = 0.621371192;
  static const double milesToKm = 1.609344;
  static const double metersPerSecondToKmh = 3.6;
  static const double metersToFeet = 3.28084;

  // Interaction Safeguards
  static const int resetHoldDurationMs = 1500;
}
