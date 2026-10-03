import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';
import 'package:odo_hud/models/telemetry_state.dart';
import 'package:odo_hud/ui/widgets/action_bar.dart';
import 'package:odo_hud/ui/widgets/auxiliary_grid.dart';
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

    testWidgets('TopStatusBar displays GPS lock and battery level',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopStatusBar(
              isGpsLocked: true,
              gpsAccuracyMeters: 3.0,
              batteryPercent: 88,
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('GPS: LOCKED (±3M)'), findsOneWidget);
      expect(find.text('BATTERY 88%'), findsOneWidget);
    });

    testWidgets('MetricCard renders label, value and unit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              label: 'TRIP DISTANCE',
              value: '34.8',
              unit: 'KM',
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('TRIP DISTANCE'), findsOneWidget);
      expect(find.text('34.8'), findsOneWidget);
      expect(find.text('KM'), findsOneWidget);
    });

    testWidgets('AuxiliaryGrid renders all 4 telemetry tiles', (tester) async {
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
              height: 300,
              child: AuxiliaryGrid(
                telemetry: telemetry,
                theme: testTheme,
                isMetric: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('TRIP DISTANCE'), findsOneWidget);
      expect(find.text('MOVING TIME'), findsOneWidget);
      expect(find.text('00:42:15'), findsOneWidget);
      expect(find.text('AVG SPEED'), findsOneWidget);
      expect(find.text('HEADING'), findsOneWidget);
      expect(find.text('NW 315°'), findsOneWidget);
    });

    testWidgets('ActionBar toggles HUD button and triggers onToggleHud callback',
        (tester) async {
      bool hudToggled = false;
      bool settingsOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isHudMirrored: false,
              onToggleHud: () => hudToggled = true,
              onOpenSettings: () => settingsOpened = true,
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('HUD MIRROR'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('RESET (HOLD)'), findsOneWidget);

      await tester.tap(find.text('HUD MIRROR'));
      expect(hudToggled, isTrue);

      await tester.tap(find.text('SETTINGS'));
      expect(settingsOpened, isTrue);
    });
  });
}
