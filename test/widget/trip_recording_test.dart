import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';
import 'package:odo_hud/data/models/trip_record.dart';
import 'package:odo_hud/ui/screens/trip_history_screen.dart';
import 'package:odo_hud/ui/widgets/action_bar.dart';
import 'package:odo_hud/ui/widgets/top_status_bar.dart';

void main() {
  final testTheme = HudTheme(ThemeConfigRecord()..id = 1);

  group('Trip Recording & Toolbar Tests', () {
    testWidgets(
        'TopStatusBar shows active recording badge when isRecordingTrip is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopStatusBar(
              isGpsLocked: true,
              gpsAccuracyMeters: 2.0,
              theme: testTheme,
              onOpenSettings: () {},
              onOpenTripHistory: () {},
              isRecordingTrip: true,
              recordedTripSeconds: 125, // 00:02:05
              recordedTripDistanceKm: 1.4,
            ),
          ),
        ),
      );

      // Verify GPS lock pill is rendered
      expect(find.text('GPS'), findsOneWidget);

      // Verify REC pill is rendered with formatted time and distance
      expect(find.textContaining('REC'), findsOneWidget);
      expect(find.textContaining('00:02:05'), findsOneWidget);
      expect(find.textContaining('1.4 km'), findsOneWidget);

      // Verify battery and clock are NOT present
      expect(find.byIcon(Icons.battery_charging_full_rounded), findsNothing);
      expect(find.byIcon(Icons.battery_alert_rounded), findsNothing);
    });

    testWidgets('ActionBar toggles between Start Trip and Stop Trip states',
        (tester) async {
      bool recordToggled = false;

      // When NOT recording
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isHudMirrored: false,
              onToggleHud: () {},
              isLandscape: false,
              onToggleOrientation: () {},
              isRecordingTrip: false,
              onToggleRecording: () => recordToggled = true,
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Stop'), findsNothing);

      await tester.tap(find.text('Start'));
      expect(recordToggled, isTrue);

      // When recording IS active
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isHudMirrored: false,
              onToggleHud: () {},
              isLandscape: false,
              onToggleOrientation: () {},
              isRecordingTrip: true,
              onToggleRecording: () {},
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
    });

    testWidgets('ActionBar toggles between Pause and Resume states',
        (tester) async {
      bool pauseToggled = false;

      // Active recording and not paused
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isRecordingTrip: true,
              onToggleRecording: () {},
              isTripPaused: false,
              onTogglePause: () => pauseToggled = true,
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      expect(pauseToggled, isTrue);

      // Active recording and paused
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isRecordingTrip: true,
              onToggleRecording: () {},
              isTripPaused: true,
              onTogglePause: () {},
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets(
        'TripHistoryScreen renders empty state without throwing type error',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TripHistoryScreen(
              tripsStream: Stream.value(<TripRecord>[]),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Trip History'), findsOneWidget);
      expect(find.text('No Recorded Rides Yet'), findsOneWidget);
      expect(find.text('Back to Dashboard'), findsOneWidget);
    });

    testWidgets('TripHistoryScreen renders sleek stats cards at top with rides',
        (tester) async {
      final trip1 = TripRecord()
        ..id = 1
        ..title = 'Sunday Morning Ride'
        ..startTime = DateTime(2026, 10, 4, 9, 0)
        ..distanceKm = 15.0
        ..durationSeconds = 1800
        ..movingDurationSeconds = 1800
        ..avgSpeedKmh = 30.0
        ..topSpeedKmh = 50.0;

      final trip2 = TripRecord()
        ..id = 2
        ..title = 'Sunset Cruise'
        ..startTime = DateTime(2026, 10, 3, 18, 0)
        ..distanceKm = 25.0
        ..durationSeconds = 3600
        ..movingDurationSeconds = 3600
        ..avgSpeedKmh = 25.0
        ..topSpeedKmh = 60.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TripHistoryScreen(
              tripsStream: Stream.value([trip1, trip2]),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      // Verify Lifetime telemetry header & ride badge
      expect(find.text('LIFETIME TELEMETRY'), findsOneWidget);
      expect(find.text('2 rides'), findsOneWidget);

      // Verify all 4 sleek stat cards
      expect(find.text('TOTAL DISTANCE'), findsOneWidget);
      expect(find.text('40.0'), findsOneWidget); // 15 + 25
      expect(find.text('TIME IN SADDLE'), findsOneWidget);
      expect(find.text('01:30:00'), findsOneWidget); // 1800 + 3600 = 5400s = 1h 30m
      expect(find.text('RECORD PEAK'), findsOneWidget);
      expect(find.text('60'), findsOneWidget); // max(50, 60)
      expect(find.text('AVG PER RIDE'), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget); // 40 / 2 = 20
    });
  });
}
