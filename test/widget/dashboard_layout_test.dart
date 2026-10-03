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

      expect(find.text('GPS Connected (±3m)'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
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

      expect(find.text('Trip Distance'), findsOneWidget);
      expect(find.text('Moving Time'), findsOneWidget);
      expect(find.text('00:42:15'), findsOneWidget);
      expect(find.text('Average Speed'), findsOneWidget);
      expect(find.text('Heading'), findsOneWidget);
      expect(find.text('NW 315°'), findsOneWidget);
    });

    testWidgets('ActionBar toggles HUD button and triggers onToggleHud callback',
        (tester) async {
      bool hudToggled = false;
      bool orientationToggled = false;
      bool settingsOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionBar(
              isHudMirrored: false,
              onToggleHud: () => hudToggled = true,
              isLandscape: false,
              onToggleOrientation: () => orientationToggled = true,
              onOpenSettings: () => settingsOpened = true,
              onResetTrip: () {},
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.text('HUD Flip'), findsOneWidget);
      expect(find.text('Landscape'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Reset Trip'), findsOneWidget);

      await tester.tap(find.text('HUD Flip'));
      expect(hudToggled, isTrue);

      await tester.tap(find.text('Landscape'));
      expect(orientationToggled, isTrue);

      await tester.tap(find.text('Settings'));
      expect(settingsOpened, isTrue);
    });
  });
}
