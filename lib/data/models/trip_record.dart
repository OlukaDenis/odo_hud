import 'package:isar/isar.dart';

part 'trip_record.g.dart';

@collection
class TripRecord {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  DateTime? endTime;

  double distanceKm = 0.0;
  double topSpeedKmh = 0.0;
  double avgSpeedKmh = 0.0;
  int durationSeconds = 0; // Total duration in seconds

  String title = '';
  bool isCompleted = true;
}
