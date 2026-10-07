import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/theme/hud_theme.dart';
import 'package:odo_hud/data/models/theme_config_record.dart';
import 'package:odo_hud/models/telemetry_state.dart';
import 'package:odo_hud/providers/telemetry_provider.dart';
import 'package:odo_hud/providers/theme_provider.dart';
import 'package:odo_hud/ui/widgets/compass/compass_bottom_sheet.dart';
import 'package:odo_hud/ui/widgets/compass/compass_card.dart';
import 'package:odo_hud/ui/widgets/compass/compass_dial.dart';

void main() {
  final testTheme = HudTheme(ThemeConfigRecord());

  group('Compass Widget Tests', () {
    testWidgets('CompassDial renders custom paint with smooth needle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompassDial(
              headingDegrees: 180.0,
              size: 100,
              theme: testTheme,
            ),
          ),
        ),
      );

      expect(find.byType(CompassDial), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'CompassCard renders mini dial, heading, and opens sheet on tap',
      (tester) async {
        const telemetry = TelemetryState(
          headingDegrees: 315.0,
          cardinalDirection: 'NW',
          altitudeMeters: 1250.0,
          latitude: 0.3476,
          longitude: 32.5825,
          gpsAccuracyMeters: 3.5,
          isGpsLocked: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              telemetryProvider.overrideWith(
                (ref) => _MockTelemetryNotifier(telemetry),
              ),
              hudThemeProvider.overrideWithValue(testTheme),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 200,
                  height: 100,
                  child: CompassCard(
                    telemetry: telemetry,
                    theme: testTheme,
                    isMetric: true,
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify header and mini dial
        expect(find.text('Compass'), findsOneWidget);
        expect(find.byType(CompassDial), findsOneWidget);
        expect(find.byIcon(Icons.open_in_full_rounded), findsOneWidget);

        // Tap card to open expanded sheet
        await tester.tap(find.byType(CompassCard));
        await tester.pumpAndSettle();

        // Verify bottom sheet contents
        expect(find.text('Compass & Navigation'), findsOneWidget);
        expect(find.text('NW · North-West'), findsOneWidget);
        expect(find.text('1250 m'), findsOneWidget);
        expect(find.text('± 3.5 m'), findsOneWidget);
        expect(find.text('Signal Locked'), findsOneWidget);
        expect(find.text('0.3476° N, 32.5825° E'), findsOneWidget);
      },
    );
  });
}

class _MockTelemetryNotifier extends StateNotifier<TelemetryState>
    implements TelemetryNotifier {
  _MockTelemetryNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
