import 'dart:convert';
import 'package:isar/isar.dart';

part 'trip_record.g.dart';

class TripEvent {
  final String type; // 'start', 'pause', 'resume', 'stop'
  final DateTime timestamp;
  final double distanceKm;
  final double? speedKmh;

  const TripEvent({
    required this.type,
    required this.timestamp,
    required this.distanceKm,
    this.speedKmh,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'distanceKm': distanceKm,
        if (speedKmh != null) 'speedKmh': speedKmh,
      };

  factory TripEvent.fromJson(Map<String, dynamic> json) => TripEvent(
        type: json['type'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      );
}

@collection
class TripRecord {
  Id id = Isar.autoIncrement;

  late DateTime startTime;
  DateTime? endTime;

  double distanceKm = 0.0;
  double topSpeedKmh = 0.0;
  double avgSpeedKmh = 0.0;
  int durationSeconds = 0; // Total duration in seconds (elapsed)
  int movingDurationSeconds = 0; // Active moving seconds
  int pauseDurationSeconds = 0; // Paused/stopped seconds

  String title = '';
  bool isCompleted = true;

  String? eventsJson;

  @ignore
  List<TripEvent> get events {
    if (eventsJson == null || eventsJson!.isEmpty) return [];
    try {
      final list = jsonDecode(eventsJson!) as List<dynamic>;
      return list
          .map((e) => TripEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  set events(List<TripEvent> list) {
    eventsJson = jsonEncode(list.map((e) => e.toJson()).toList());
  }
}
