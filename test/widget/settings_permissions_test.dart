import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/ui/screens/permissions_screen.dart';
import 'package:odo_hud/ui/screens/settings_screen.dart';

void main() {
  group('Settings & Permissions Screen Tests', () {
    testWidgets('SettingsScreen renders speed units at top and section cards',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Speed & Distance Units Card is present on top
      expect(find.text('SPEED & DISTANCE UNITS'), findsOneWidget);
      expect(find.text('Speed Unit'), findsOneWidget);
      expect(find.text('Distance Unit'), findsOneWidget);
      expect(find.text('KM/H'), findsOneWidget);
      expect(find.text('KM'), findsOneWidget);

      // Verify Speed Calibration & Offset Card
      expect(find.text('Speed Calibration & Offset'), findsOneWidget);

      // Verify Appearance & Theme Card
      await tester.scrollUntilVisible(
        find.text('Theme Appearance'),
        150,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('APPEARANCE & THEME'), findsOneWidget);
      expect(find.text('Theme Appearance'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Speedometer Font'), findsOneWidget);
      expect(find.text('Primary & Speed Display Colors'), findsOneWidget);

      // Scroll down to permissions and speed alerts
      await tester.scrollUntilVisible(
        find.text('PERMISSIONS & SYSTEM TUNING'),
        300,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('SPEED ALERTS & SAFETY'), findsOneWidget);
      expect(find.text('Speed Alert Thresholds'), findsOneWidget);
      expect(find.text('PERMISSIONS & SYSTEM TUNING'), findsOneWidget);
      expect(find.text('Hardware & Background Access'), findsOneWidget);
    });

    testWidgets('PermissionsScreen renders detailed system and OEM tuning',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PermissionsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Header
      expect(find.text('PERMISSIONS & SYSTEM TUNING'), findsOneWidget);

      // Verify Detailed Permission Items
      expect(find.text('GPS Location'), findsOneWidget);
      expect(find.text('HUD Notification'), findsOneWidget);
      expect(find.text('Battery Whitelist'), findsOneWidget);
      expect(find.text('OEM Autostart Guide'), findsOneWidget);
      expect(find.text('Open OEM Step-by-Step Guide'), findsOneWidget);
    });
  });
}
