import 'package:flutter/material.dart';
import 'constants/app_strings.dart';

/// Enum defining supported medication types.
enum MedicationType {
  tablet,
  capsule,
  injection,
  drops,
  inhaler,
  ointmentCream,
  patch,
  nasalSpray,
  suppository,
}

/// Enum defining quantity types for medications.
enum MedicationQuantityType {
  tablet,
  capsule,
  vial,
  ampule,
  bottle,
  inhaler,
  tube,
  jar,
  box,
  puff,
  dose,
  spray,
  suppository,
}

/// Enum defining administration methods for medications.
enum MedicationAdministrationType {
  none,
  syringe,
  dropper,
  inhaler,
  applicator,
  finger,
  patch,
  pump,
  suppository,
}

/// Core class for managing medication configurations, unit conversions, and dose calculations.
class MedicationMatrix {
  /// Matrix mapping each MedicationType to its configuration.
  static const Map<MedicationType, Map<String, dynamic>> matrix = {
    MedicationType.tablet: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.tablet],
      'quantityUnits': ['Tablet'],
      'quantityRange': [0.25, 100.0], // Tighter range for tablets
      'administrationType': MedicationAdministrationType.none,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['mg', 'mcg'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.capsule: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.capsule],
      'quantityUnits': ['Capsule'],
      'quantityRange': [0.25, 100.0],
      'administrationType': MedicationAdministrationType.none,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['mg', 'mcg'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.drops: {
      'concentrationUnits': ['mg/mL', 'mcg/mL'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.vial, MedicationQuantityType.bottle],
      'quantityUnits': ['mL'],
      'quantityRange': [0.01, 100.0],
      'administrationType': MedicationAdministrationType.dropper,
      'administrationSizes': [0.025, 0.05, 0.1], // Common dropper sizes
      'calculationRequired': true,
      'administrationUnits': ['mL', 'drop'],
      'administrationRange': [0.01, 10.0], // Smaller range for drops
    },
    MedicationType.injection: {
      'concentrationUnits': ['mg/mL', 'mcg/mL'],
      'concentrationRange': [0.0001, 999.0],
      'quantityType': [MedicationQuantityType.vial, MedicationQuantityType.ampule],
      'quantityUnits': ['mL'],
      'quantityRange': [0.01, 50.0], // Tighter range for injections
      'administrationType': MedicationAdministrationType.syringe,
      'administrationSizes': [0.3, 0.5, 1.0, 3.0, 5.0],
      'calculationRequired': true,
      'administrationUnits': ['mL'],
      'administrationRange': [0.01, 10.0],
    },
    MedicationType.inhaler: {
      'concentrationUnits': ['mcg/puff', 'mg/puff'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.inhaler],
      'quantityUnits': ['Puff', 'Dose'],
      'quantityRange': [1.0, 200.0], // Puffs per canister
      'administrationType': MedicationAdministrationType.inhaler,
      'administrationSizes': [], // Inhalers typically have fixed puff sizes
      'calculationRequired': true, // For puff-based dosing
      'administrationUnits': ['puff'],
      'administrationRange': [1.0, 10.0], // Max puffs per dose
    },
    MedicationType.ointmentCream: {
      'concentrationUnits': ['% (w/w)', 'mg/g', 'mcg/g'],
      'concentrationRange': [0.01, 100.0], // % up to 100
      'quantityType': [MedicationQuantityType.tube, MedicationQuantityType.jar],
      'quantityUnits': ['g', 'mL'],
      'quantityRange': [1.0, 500.0], // Common tube/jar sizes
      'administrationType': MedicationAdministrationType.applicator,
      'administrationSizes': [0.5, 1.0, 2.0], // Fingertip units
      'calculationRequired': true,
      'administrationUnits': ['g', 'cm'],
      'administrationRange': [0.1, 50.0],
    },
    MedicationType.patch: {
      'concentrationUnits': ['mg/day', 'mcg/hr'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.box],
      'quantityUnits': ['Patch'],
      'quantityRange': [1.0, 30.0], // Patches per box
      'administrationType': MedicationAdministrationType.patch,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['patch'],
      'administrationRange': [1.0, 2.0], // Typically 1 patch
    },
    MedicationType.nasalSpray: {
      'concentrationUnits': ['mg/mL', 'mcg/spray'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.bottle],
      'quantityUnits': ['Spray', 'mL'],
      'quantityRange': [1.0, 100.0],
      'administrationType': MedicationAdministrationType.pump,
      'administrationSizes': [0.05, 0.1], // Spray volumes
      'calculationRequired': true,
      'administrationUnits': ['spray'],
      'administrationRange': [1.0, 10.0], // Sprays per dose
    },
    MedicationType.suppository: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.box],
      'quantityUnits': ['Suppository'],
      'quantityRange': [1.0, 30.0],
      'administrationType': MedicationAdministrationType.suppository,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['suppository'],
      'administrationRange': [1.0, 2.0],
    },
  };

  /// Conversion factors for units (in mg or mL where applicable).
  static const Map<String, double> unitConversions = {
    'mg': 1.0,
    'mcg': 0.001,
    'mL': 1.0,
    'g': 1000.0, // 1000 mg per g
    'cm': 0.5, // Approx 0.5g per cm for ointment (fingertip unit)
    'spray': 0.1, // Default for nasal spray
    'puff': 1.0, // Inhaler-specific
    'drop': 0.05, // Default drop size; override with dropSizeML
    'patch': 1.0, // Single patch
    'suppository': 1.0, // Single suppository
  };

  /// Returns valid concentration units for a medication type.
  static List<String> getConcentrationUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['concentrationUnits']);
  }

  /// Returns valid quantity units for a medication type.
  static List<String> getQuantityUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['quantityUnits']);
  }

  /// Returns valid administration units for a medication type.
  static List<String> getAdministrationUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['administrationUnits']);
  }

  /// Checks if dose calculation is required for a medication type.
  static bool isCalculationRequired(MedicationType type) {
    return matrix[type]!['calculationRequired'] as bool;
  }

  /// Returns available administration sizes (e.g., syringe sizes) for a medication type.
  static List<double> getAdministrationSizes(MedicationType type) {
    return List<double>.from(matrix[type]!['administrationSizes']);
  }

  /// Converts a value between units, with optional drop size override.
  static double convertUnit(double value, String fromUnit, String toUnit, {double? dropSizeML}) {
    if (fromUnit == toUnit) return value;
    final effectiveFrom = fromUnit == 'drop' && dropSizeML != null ? dropSizeML : unitConversions[fromUnit] ?? 1.0;
    final effectiveTo = toUnit == 'drop' && dropSizeML != null ? dropSizeML : unitConversions[toUnit] ?? 1.0;
    if (effectiveFrom == 0 || effectiveTo == 0) {
      throw Exception('Invalid unit: $fromUnit or $toUnit');
    }
    return value * effectiveFrom / effectiveTo;
  }

  /// Calculates the administration dose (e.g., mL for injections, puffs for inhalers).
  static double calculateAdministrationDose({
    required MedicationType type,
    required double concentrationValue,
    required String concentrationUnit,
    required double desiredDose,
    required String doseUnit,
    double? dropSizeML,
  }) {
    if (!isCalculationRequired(type)) return desiredDose;

    // Convert desired dose to concentration unit
    final doseInConcentrationUnit = convertUnit(desiredDose, doseUnit, concentrationUnit, dropSizeML: dropSizeML);

    // Calculate volume or quantity
    switch (type) {
      case MedicationType.injection:
      case MedicationType.drops:
        if (concentrationUnit.contains('/mL')) {
          return doseInConcentrationUnit / concentrationValue; // e.g., 0.25 mg / 2 mg/mL = 0.125 mL
        }
        break;
      case MedicationType.inhaler:
        if (concentrationUnit.contains('/puff')) {
          return doseInConcentrationUnit / concentrationValue; // e.g., 100 mcg / 50 mcg/puff = 2 puffs
        }
        break;
      case MedicationType.ointmentCream:
        if (concentrationUnit.contains('/g') || concentrationUnit == '% (w/w)') {
          return doseInConcentrationUnit / (concentrationUnit == '% (w/w)' ? concentrationValue * 10 : concentrationValue); // % to mg/g
        }
        break;
      case MedicationType.nasalSpray:
        if (concentrationUnit.contains('/spray')) {
          return doseInConcentrationUnit / concentrationValue; // e.g., 100 mcg / 50 mcg/spray = 2 sprays
        }
        break;
      default:
        break;
    }
    throw Exception('Unsupported calculation for $type with $concentrationUnit');
  }

  /// Validates a value against the allowed range for a given type and field.
  static bool isValidValue(MedicationType type, double value, String field) {
    if (value <= 0) return false;
    final range = matrix[type]![
    field == 'concentration' ? 'concentrationRange' : field == 'quantity' ? 'quantityRange' : 'administrationRange'] as List<double>;
    return value >= range[0] && value <= range[1];
  }

  /// Maps a database Medication.form string to a MedicationType.
  static MedicationType formToType(String form) {
    final normalizedForm = form.toLowerCase().replaceAll('/', '').replaceAll(' ', '');
    return MedicationType.values.firstWhere(
          (type) => type.toString().split('.').last == normalizedForm,
      orElse: () => MedicationType.tablet,
    );
  }
}