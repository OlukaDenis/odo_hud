import 'package:flutter_test/flutter_test.dart';
import 'package:odo_hud/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter Tests', () {
    test('kmh to mph conversion', () {
      expect(UnitConverter.kmhToMph(100.0), closeTo(62.137, 0.01));
      expect(UnitConverter.kmhToMph(0.0), equals(0.0));
      expect(UnitConverter.kmhToMph(50.0), closeTo(31.068, 0.01));
    });

    test('mph to kmh conversion', () {
      expect(UnitConverter.mphToKmh(60.0), closeTo(96.56, 0.01));
      expect(UnitConverter.mphToKmh(0.0), equals(0.0));
    });

    test('meters to km and miles conversion', () {
      expect(UnitConverter.metersToKm(1500.0), equals(1.5));
      expect(UnitConverter.metersToMiles(1609.344), closeTo(1.0, 0.01));
    });

    test('mps to kmh conversion', () {
      expect(UnitConverter.mpsToKmh(10.0), equals(36.0));
      expect(UnitConverter.mpsToKmh(0.416667), closeTo(1.5, 0.01));
    });

    test('degreesToCardinal conversion', () {
      expect(UnitConverter.degreesToCardinal(0), equals('N'));
      expect(UnitConverter.degreesToCardinal(360), equals('N'));
      expect(UnitConverter.degreesToCardinal(45), equals('NE'));
      expect(UnitConverter.degreesToCardinal(90), equals('E'));
      expect(UnitConverter.degreesToCardinal(135), equals('SE'));
      expect(UnitConverter.degreesToCardinal(180), equals('S'));
      expect(UnitConverter.degreesToCardinal(225), equals('SW'));
      expect(UnitConverter.degreesToCardinal(270), equals('W'));
      expect(UnitConverter.degreesToCardinal(315), equals('NW'));
      expect(UnitConverter.degreesToCardinal(350), equals('N'));
    });

    test('formatMovingTime formatting', () {
      expect(UnitConverter.formatMovingTime(0), equals('00:00:00'));
      expect(UnitConverter.formatMovingTime(65), equals('00:01:05'));
      expect(UnitConverter.formatMovingTime(3665), equals('01:01:05'));
    });
  });
}
