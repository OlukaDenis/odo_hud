import 'package:isar/isar.dart';

part 'telemetry_record.g.dart';

@collection
class TelemetryRecord {
  Id id = 1; // Single-row singleton for persistent totals

  double lifetimeOdometerMeters = 0.0;
  double activeTripMeters = 0.0;
  int activeTripMovingSeconds = 0;
  double maxSpeedKmh = 0.0;
  DateTime lastSavedTimestamp = DateTime.now();
}
