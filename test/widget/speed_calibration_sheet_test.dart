import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/providers/speed_calibration_provider.dart';
import 'package:odo_hud/ui/widgets/settings/speed_calibration_card.dart';

void main() {
  group('SpeedCalibration UI Tests', () {
    testWidgets('SpeedCalibrationCard renders and opens SpeedCalibrationSheet',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SpeedCalibrationCard(),
            ),
          ),
        ),
      );

      // Verify card components
      expect(find.text('SPEEDOMETER CALIBRATION'), findsOneWidget);
      expect(find.text('Speed Calibration'), findsOneWidget);
      expect(find.text('OFF'), findsOneWidget);

      // Tap card to open modal sheet
      await tester.tap(find.text('Speed Calibration'));
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('SPEED CALIBRATION OFFSET'), findsOneWidget);
      expect(find.text('Enable Speed Calibration'), findsOneWidget);
      expect(find.text('AUTOMOTIVE CALIBRATION PRESETS'), findsOneWidget);
      expect(find.text('LIVE HUD SIMULATION PREVIEW'), findsOneWidget);
      expect(find.text('Percentage Offset (Tire / Proportional)'), findsOneWidget);
      expect(find.text('True GPS (0%)'), findsOneWidget);
      expect(find.text('Factory +5%'), findsOneWidget);
      expect(find.text('Factory +8%'), findsOneWidget);
      expect(find.text('UNECE (+7% + 2 km/h)'), findsOneWidget);

      // Tap preset Factory +5%
      await tester.tap(find.text('Factory +5%'));
      await tester.pumpAndSettle();

      // Verify preset applied
      final container = ProviderScope.containerOf(tester.element(find.byType(SpeedCalibrationCard)));
      final config = container.read(speedCalibrationProvider);
      expect(config.isEnabled, isTrue);
      expect(config.percentageOffset, equals(5.0));
      expect(config.fixedOffsetKmh, equals(0.0));
    });
  });
}
