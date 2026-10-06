import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/data/models/trip_record.dart';
import 'package:odo_hud/ui/screens/trip_detail_screen.dart';

void main() {
  group('TripDetailScreen Tests', () {
    testWidgets('renders all trip details and events correctly',
        (tester) async {
      final now = DateTime(2026, 10, 5, 8, 30);
      final trip = TripRecord()
        ..id = 1
        ..title = 'Morning Canyon Ride'
        ..startTime = now
        ..endTime = now.add(const Duration(minutes: 45))
        ..distanceKm = 24.5
        ..durationSeconds = 2700 // 45 min
        ..movingDurationSeconds = 2400 // 40 min
        ..pauseDurationSeconds = 300 // 5 min
        ..avgSpeedKmh = 36.75
        ..topSpeedKmh = 64.2
        ..isCompleted = true;

      trip.events = [
        TripEvent(
          type: 'start',
          timestamp: now,
          distanceKm: 0.0,
          speedKmh: 0.0,
        ),
        TripEvent(
          type: 'pause',
          timestamp: now.add(const Duration(minutes: 20)),
          distanceKm: 12.0,
          speedKmh: 0.0,
        ),
        TripEvent(
          type: 'resume',
          timestamp: now.add(const Duration(minutes: 25)),
          distanceKm: 12.0,
          speedKmh: 20.0,
        ),
        TripEvent(
          type: 'stop',
          timestamp: now.add(const Duration(minutes: 45)),
          distanceKm: 24.5,
          speedKmh: 0.0,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TripDetailScreen(trip: trip),
          ),
        ),
      );

      // 1. Verify Header
      expect(find.text('Morning Canyon Ride'), findsOneWidget);
      expect(find.text('Ride Details'), findsOneWidget);

      // 2. Verify Primary Stats
      expect(find.text('24.50'), findsOneWidget); // Distance
      expect(find.text('00:40:00'), findsOneWidget); // Moving Time
      expect(find.text('36.8'), findsOneWidget); // Avg Speed
      expect(find.text('64.2'), findsOneWidget); // Peak Speed

      // 3. Verify Tempo & Rest Breakdown
      expect(find.text('RIDE TEMPO & REST TIME'), findsOneWidget);
      expect(find.textContaining('In Motion: 00:40:00'), findsOneWidget);
      expect(find.textContaining('Stopped / Idle: 00:05:00'), findsOneWidget);

      // 4. Verify Journey Timeline Events
      expect(find.text('JOURNEY TIMELINE & EVENTS'), findsOneWidget);
      expect(find.text('Ride Started'), findsOneWidget);
      expect(find.text('Ride Paused / Rest Stop'), findsOneWidget);
      expect(find.text('Ride Resumed'), findsOneWidget);
      expect(find.text('Ride Finished & Saved'), findsOneWidget);
    });
  });
}
