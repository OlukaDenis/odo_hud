import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/ui/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen Tests', () {
    testWidgets('SplashScreen displays logo, title, and telemetry progress bar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify Project Logo Image widget is rendered
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(
        (imageWidget.image as AssetImage).assetName,
        equals('assets/app_icon.png'),
      );

      // Verify branding typography and subtitle
      expect(find.text('ODOHUD'), findsOneWidget);
      expect(find.text('HIGH-FREQUENCY TELEMETRY HUD'), findsOneWidget);

      // Verify loading indicator and telemetry initialization text
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('INITIALIZING TELEMETRY...'), findsOneWidget);

      // Pump animation through the 2-second progression
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
