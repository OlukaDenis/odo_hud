import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';
import 'package:odo_hud/models/telemetry_state.dart';
import 'package:odo_hud/ui/widgets/action_bar.dart';
import 'package:odo_hud/ui/widgets/auxiliary_grid.dart';
import 'package:odo_hud/ui/widgets/compass/compass_dial.dart';
import 'package:odo_hud/ui/widgets/metric_card.dart';
import 'package:odo_hud/ui/widgets/speed_display.dart';
import 'package:odo_hud/ui/widgets/top_status_bar.dart';

void main() {
  late HudTheme testTheme;

  setUp(() {
    final config = ThemeConfigRecord()..id = 1;
    testTheme = HudTheme(config);
  });

  group('HUD Widget Tests', () {
    testWidgets('SpeedDisplay renders correct speed and metric unit',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpeedDisplay(
              currentSpeed: 88,
              speedKmh: 88,
              isMetric: true,
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('88'), findsOneWidget);
      expect(find.text('KM / H'), findsOneWidget);
    });

    testWidgets('SpeedDisplay renders imperial MPH unit when isMetric is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpeedDisplay(
              currentSpeed: 55,
              speedKmh: 88.5,
              isMetric: false,
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('55'), findsOneWidget);
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('TopStatusBar (TopToolbar) displays GPS lock and action buttons',
        (tester) async {
      bool settingsOpened = false;
      bool historyOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopStatusBar(
              isGpsLocked: true,
              gpsAccuracyMeters: 3.0,
              theme: testTheme,
              onOpenSettings: () => settingsOpened = true,
              onOpenTripHistory: () => historyOpened = true,
            ),
          ),
        ),
      );

      expect(find.text('GPS'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byIcon(Icons.history_rounded));
      expect(historyOpened, isTrue);

      await tester.tap(find.byIcon(Icons.settings));
      expect(settingsOpened, isTrue);
    });

    testWidgets('MetricCard renders label, value and unit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'Trip Distance',
              value: '34.8',
              unit: 'KM',
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('Trip Distance'), findsOneWidget);
      expect(find.text('34.8'), findsOneWidget);
      expect(find.text('KM'), findsOneWidget);
    });

    testWidgets(
        'AuxiliaryGrid renders all 4 telemetry tiles and top icon-only actions',
        (tester) async {
      bool hudToggled = false;
      bool orientationToggled = false;

      const telemetry = TelemetryState(
        tripDistanceKm: 34.8,
        movingTimeSeconds: 2535, // 00:42:15
        averageSpeedKmh: 52.0,
        headingDegrees: 315.0,
        cardinalDirection: 'NW',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: AuxiliaryGrid(
                telemetry: telemetry,
                theme: testTheme,
                isMetric: true,
                isHudMirrored: false,
                onToggleHud: () => hudToggled = true,
                isLandscape: false,
                onToggleOrientation: () => orientationToggled = true,
              ),
            ),
          ),
        ),
      );

      // Verify metric cards
      expect(find.text('Trip Distance'), findsOneWidget);
      expect(find.text('Moving Time'), findsOneWidget);
      expect(find.text('00:42:15'), findsOneWidget);
      expect(find.text('Average Speed'), findsOneWidget);
      expect(find.text('Heading'), findsOneWidget);
      expect(find.byType(CompassDial), findsOneWidget);

      // Verify icon-only buttons (no text for HUD Flip or Landscape)
      expect(find.text('HUD Flip'), findsNothing);
      expect(find.text('Landscape'), findsNothing);
      expect(find.byIcon(Icons.flip_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stay_current_landscape_rounded), findsOneWidget);

      // Tap HUD Flip icon
      await tester.tap(find.byIcon(Icons.flip_rounded));
      expect(hudToggled, isTrue);

      // Tap Landscape icon
      await tester.tap(find.byIcon(Icons.stay_current_landscape_rounded));
      expect(orientationToggled, isTrue);
    });

    testWidgets(
        'ActionBar renders enlarged Start, Pause, and Reset actions',
        (tester) async {
      bool tripToggled = false;
      bool pauseToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isRecordingTrip: true,
              onToggleRecording: () => tripToggled = true,
              isTripPaused: false,
              onTogglePause: () => pauseToggled = true,
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('Stop'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // Verify HUD flip & landscape are NOT in bottom action bar
      expect(find.byIcon(Icons.flip_rounded), findsNothing);
      expect(find.byIcon(Icons.stay_current_landscape_rounded), findsNothing);

      await tester.tap(find.text('Stop'));
      expect(tripToggled, isTrue);

      await tester.tap(find.byIcon(Icons.pause_rounded));
      expect(pauseToggled, isTrue);
    });
  });
}
