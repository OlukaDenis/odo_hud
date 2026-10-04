import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/ui/screens/settings_screen.dart';

void main() {
  group('Settings Screen Permissions & System Tuning Tests', () {
    testWidgets('SettingsScreen renders permissions section and items',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll down to permissions section
      await tester.scrollUntilVisible(
        find.text('PERMISSIONS & SYSTEM TUNING'),
        300,
        scrollable: find.byType(Scrollable),
      );

      // Verify Section Header
      expect(find.text('PERMISSIONS & SYSTEM TUNING'), findsOneWidget);

      // Verify Permission Items
      expect(find.text('GPS Location'), findsOneWidget);
      expect(find.text('HUD Notification'), findsOneWidget);
      expect(find.text('Battery Whitelist'), findsOneWidget);
      expect(find.text('OEM Autostart Guide'), findsOneWidget);
    });
  });
}
