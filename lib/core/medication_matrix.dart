// lib/core/medication_matrix.dart
import 'package:flutter/material.dart';

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

class MedicationMatrix {
  static const Map<MedicationType, Map<String, dynamic>> matrix = {
    MedicationType.tablet: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.tablet],
      'quantityUnits': ['Tablet'],
      'quantityRange': [0.01, 999.0],
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
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.none,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['mg', 'mcg'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.injection: {
      'concentrationUnits': ['mg/mL', 'mcg/mL', 'IU/mL'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.vial, MedicationQuantityType.ampule],
      'quantityUnits': ['mL', 'IU'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.syringe,
      'administrationSizes': [0.3, 0.5, 1.0, 3.0, 5.0],
      'calculationRequired': true,
      'administrationUnits': ['mL', 'IU'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.drops: {
      'concentrationUnits': ['mg/mL', 'mcg/mL', 'Drop'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.vial, MedicationQuantityType.bottle],
      'quantityUnits': ['mL', 'Drop'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.dropper,
      'administrationSizes': [0.3, 0.5, 1.0],
      'calculationRequired': true,
      'administrationUnits': ['mL', 'Drop'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.inhaler: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.inhaler],
      'quantityUnits': ['Puff', 'Dose'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.inhaler,
      'administrationSizes': [],
      'calculationRequired': false, // Sometimes, but default to false
      'administrationUnits': ['mg', 'mcg'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.ointmentCream: {
      'concentrationUnits': ['% (w/w)', 'mg/g', 'mcg/g'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.tube, MedicationQuantityType.jar],
      'quantityUnits': ['g', 'mL'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.applicator,
      'administrationSizes': [],
      'calculationRequired': true,
      'administrationUnits': ['g', 'cm'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.patch: {
      'concentrationUnits': ['mg', 'mcg', 'mg/hr'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.box],
      'quantityUnits': ['Patch'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.patch,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['mg', 'mcg', 'mg/hr'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.nasalSpray: {
      'concentrationUnits': ['mg/mL', 'mcg/spray'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.bottle],
      'quantityUnits': ['Spray', 'mL'],
      'administrationType': MedicationAdministrationType.pump,
      'administrationSizes': [],
      'calculationRequired': true,
      'administrationUnits': ['mcg', 'spray'],
      'administrationRange': [0.01, 999.0],
    },
    MedicationType.suppository: {
      'concentrationUnits': ['mg', 'mcg'],
      'concentrationRange': [0.01, 999.0],
      'quantityType': [MedicationQuantityType.box],
      'quantityUnits': ['Suppository'],
      'quantityRange': [0.01, 999.0],
      'administrationType': MedicationAdministrationType.suppository,
      'administrationSizes': [],
      'calculationRequired': false,
      'administrationUnits': ['mg', 'mcg'],
      'administrationRange': [0.01, 999.0],
    },
  };

  // Conversion factors for units
  static const Map<String, double> unitConversions = {
    'mg': 1.0,
    'mcg': 0.001,
    'mL': 1.0,
    'L': 1000.0,
    'cc': 1.0,
    'tsp': 4.92892,
    'tbsp': 14.7868,
    'drop': 0.05, // Default; can be overridden by user calibration
    'oz': 29.5735,
    'g': 1000.0, // 1000 mg per g
    'cm': 0.5, // Approx 0.5g per cm for ointment (fingertip unit)
    'spray': 0.05, // Default for nasal spray; can vary
    'puff': 1.0, // Placeholder; inhaler-specific
    'IU': 0.025, // Placeholder; drug-specific
  };

  // Get valid concentration units for a medication type
  static List<String> getConcentrationUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['concentrationUnits']);
  }

  // Get valid quantity units for a medication type
  static List<String> getQuantityUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['quantityUnits']);
  }

  // Get valid administration units for a medication type
  static List<String> getAdministrationUnits(MedicationType type) {
    return List<String>.from(matrix[type]!['administrationUnits']);
  }

  // Check if calculation is required
  static bool isCalculationRequired(MedicationType type) {
    return matrix[type]!['calculationRequired'] as bool;
  }

  // Get administration sizes (e.g., syringe sizes)
  static List<double> getAdministrationSizes(MedicationType type) {
    return List<double>.from(matrix[type]!['administrationSizes']);
  }

  // Convert between units
  static double convertUnit(double value, String fromUnit, String toUnit, {double? dropSizeML}) {
    if (fromUnit == toUnit) return value;
    final effectiveFrom = fromUnit == 'drop' && dropSizeML != null ? dropSizeML : unitConversions[fromUnit]!;
    final effectiveTo = toUnit == 'drop' && dropSizeML != null ? dropSizeML : unitConversions[toUnit]!;
    if (effectiveFrom == null || effectiveTo == null) {
      throw Exception('Invalid unit: $fromUnit or $toUnit');
    }
    return value * effectiveFrom / effectiveTo;
  }

  // Calculate administration dose (e.g., mL for injection, drops for eye drops)
  static double calculateAdministrationDose({
    required MedicationType type,
    required double concentrationValue,
    required String concentrationUnit,
    required double desiredDose,
    required String doseUnit,
    double? dropSizeML, // Optional for drop calibration
  }) {
    if (!isCalculationRequired(type)) return desiredDose;

    // Convert desired dose to concentration unit if different
    double doseInConcentrationUnit = convertUnit(desiredDose, doseUnit, concentrationUnit, dropSizeML: dropSizeML);

    // Calculate volume or quantity needed
    if (concentrationUnit.contains('/mL')) {
      // For injections, drops (e.g., 2 mg/mL, need 0.25 mg -> 0.125 mL)
      return doseInConcentrationUnit / concentrationValue;
    } else if (concentrationUnit == 'Drop') {
      // For drops, return number of drops
      return doseInConcentrationUnit;
    } else if (concentrationUnit.contains('/g') || concentrationUnit == '% (w/w)') {
      // For ointments (e.g., 10 mg/g, need 5 mg -> 0.5 g)
      return doseInConcentrationUnit / concentrationValue;
    } else if (concentrationUnit == 'mcg/spray') {
      // For nasal sprays (e.g., 50 mcg/spray, need 100 mcg -> 2 sprays)
      return doseInConcentrationUnit / concentrationValue;
    }
    throw Exception('Unsupported calculation for $type with $concentrationUnit');
  }

  // Validate input values against range
  static bool isValidValue(MedicationType type, double value, String unitType) {
    final range = matrix[type]![unitType == 'concentration' ? 'concentrationRange' : unitType == 'quantity' ? 'quantityRange' : 'administrationRange'] as List<double>;
    return value >= range[0] && value <= range[1];
  }
}