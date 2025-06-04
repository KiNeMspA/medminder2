// lib/core/calculations.dart
import 'constants.dart';

class MedCalculations {
  static double convertUnit(double value, String fromUnit, String toUnit) {
    final conversions = {
      'mL': 1.0,
      'L': 1000.0,
      'CC': 1.0,
      'tsp': 4.92892,
      'tbsp': 14.7868,
      'drop': 0.05,
      'oz': 29.5735,
      'mg': 1.0,
      'mcg': 0.001,
      'IU': 0.025,
    };
    if (!conversions.containsKey(fromUnit) || !conversions.containsKey(toUnit)) {
      throw Exception('Invalid unit: $fromUnit or $toUnit');
    }
    return value * conversions[fromUnit]! / conversions[toUnit]!;
  }

  static double dosePerKg(double weightKg, double doseMgPerKg, String unit) {
    if (!Units.doseUnits.contains(unit)) {
      throw Exception('Invalid dose unit: $unit');
    }
    double dose = weightKg * doseMgPerKg;
    return convertUnit(dose, 'mg', unit);
  }

  static double reconstitute(double powderMg, double solventMl, double desiredMgPerMl) {
    return powderMg / desiredMgPerMl;
  }

  static String formatNumber(double value) {
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}