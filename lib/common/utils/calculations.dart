// lib/core/calculations.dart
import '../medication_matrix.dart';

class MedCalculations {
  static double convertUnit(double value, String fromUnit, String toUnit, {double? dropSizeML}) {
    return MedicationMatrix.convertUnit(value, fromUnit, toUnit, dropSizeML: dropSizeML);
  }

  static double dosePerKg(double weightKg, double doseMgPerKg, String unit) {
    if (!MedicationMatrix.getAdministrationUnits(MedicationType.tablet).contains(unit)) {
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