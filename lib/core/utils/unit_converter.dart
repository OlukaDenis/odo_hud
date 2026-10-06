import '../constants/app_constants.dart';

class UnitConverter {
  UnitConverter._();

  static double kmhToMph(double kmh) => kmh * AppConstants.kmToMiles;
  static double mphToKmh(double mph) => mph * AppConstants.milesToKm;

  static double kmToMiles(double km) => km * AppConstants.kmToMiles;
  static double milesToKm(double miles) => miles * AppConstants.milesToKm;

  static double metersToKm(double meters) => meters / 1000.0;
  static double metersToMiles(double meters) => kmToMiles(meters / 1000.0);

  static double mpsToKmh(double mps) => mps * AppConstants.metersPerSecondToKmh;

  /// Converts heading in degrees (0-360) to a cardinal direction (N, NE, E, SE, S, SW, W, NW)
  static String degreesToCardinal(double degrees) {
    final normalized = (degrees % 360 + 360) % 360;
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((normalized + 22.5) ~/ 45) % 8;
    return directions[index];
  }

  /// Converts heading in degrees (0-360) to full cardinal direction name
  static String degreesToCardinalFullName(double degrees) {
    final normalized = (degrees % 360 + 360) % 360;
    const names = [
      'North',
      'North-East',
      'East',
      'South-East',
      'South',
      'South-West',
      'West',
      'North-West',
    ];
    final index = ((normalized + 22.5) ~/ 45) % 8;
    return names[index];
  }

  /// Formats altitude meters to metric (m) or imperial (ft)
  static String formatAltitude(double meters, bool isMetric) {
    if (isMetric) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final feet = meters * 3.28084;
      return '${feet.toStringAsFixed(0)} ft';
    }
  }

  /// Formats GPS latitude and longitude into readable coordinates
  static String formatCoordinates(double lat, double lon) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lon.abs().toStringAsFixed(4)}° $lonDir';
  }

  /// Formats seconds into HH:MM:SS
  static String formatMovingTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

