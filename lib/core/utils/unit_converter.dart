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

  /// Formats seconds into HH:MM:SS
  static String formatMovingTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
