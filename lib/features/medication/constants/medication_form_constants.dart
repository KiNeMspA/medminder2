import 'package:flutter/material.dart';
import '../../../common/constants/app_strings.dart';
import '../../../common/medication_matrix.dart';

class MedicationFormConstants {
  // Strings
  static const String addMedicationTitle = 'Add Medication';
  static const String selectTypeTitle = 'Select Medication Type';
  static const String defaultUnit = 'mg';
  static const String defaultForm = 'Tablet';
  static const String defaultDeliveryMethod = 'Prefilled Syringe';
  static const String nameLabel = 'Medication Name';
  static const String concentrationLabel = 'Concentration';
  static const String quantityLabel = 'Quantity/Volume';
  static const String unitsLabel = 'units';
  static const String nameRequiredMessage = 'Medication Name is required';
  static const String concentrationRequiredMessage = 'Concentration is required';
  static const String quantityRequiredMessage = 'Quantity/Volume is required';
  static const String invalidNumberMessage = 'Enter a valid number';
  static const String typeRequiredMessage = 'Medication Type is required';
  static const String selectTypeMessage = 'Please select a medication type';
  static const String invalidRangeMessage = 'Values out of valid range (0.01–999)';
  static const String invalidValuesMessage = 'All values must be greater than 0';
  static const String duplicateNameMessage = 'A medication with this name already exists';
  static const String medicationSavedMessage = 'Medication saved';
  static const String cancelButton = 'Cancel';
  static const String continueButton = 'Continue';
  static const String saveButton = 'Save Medication';
  static const String powderAmountLabel = 'Powder Amount';
  static const String solventVolumeLabel = 'Solvent Volume';
  static const String volumeLabel = 'Volume';
  static const String reconstitutionRequiredMessage = 'Powder amount required for reconstituted vials';
  static const String volumeRequiredMessage = 'Total volume required';


  static String errorSavingMessage(Object error) => 'Error: $error';

  // Lists
  static const List<String> forms = [
    'Tablet',
    'Capsule',
    'Injection',
    'Eye Drop',
  ];

  static const Map<MedicationType, List<String>> subTypes = {
    MedicationType.injection: [
      'Prefilled Syringe',
      'Prefilled Pen',
      'Reconstituted Vial',
      'Un-Reconstituted Vial',
    ],
  };

  // Units and Help Text
  static List<String> getConcentrationUnits(MedicationType type, String? subType) {
    switch (type) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return ['mcg', 'mg'];
      case MedicationType.injection:
        return subType == 'Un-Reconstituted Vial' ? ['mcg', 'mg'] : ['mcg', 'mg', 'mL', 'IU', 'Unit'].toSet().toList();
      case MedicationType.drops:
        return ['mcg', 'mg', 'mL'];
      default:
        return ['mg'];
    }
  }

  static String getConcentrationHelpText(MedicationType type, String? subType) {
    switch (type) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return 'What is the dose/concentration in mg or mcg per ${type.toString().split('.').last}?';
      case MedicationType.injection:
        return 'What is the dose/concentration per ${subType ?? 'Injection'}?';
      case MedicationType.drops:
        return 'What is the dose/concentration in the Vial?';
      default:
        return '';
    }
  }

  static String getQuantityHelpText(MedicationType type, String? subType) {
    final quantityUnit = getQuantityUnit(type, subType);
    return 'How many $quantityUnit in stock?';
  }

  static String getQuantityUnit(MedicationType type, String? subType) {
    switch (type) {
      case MedicationType.tablet:
        return 'Tablets';
      case MedicationType.capsule:
        return 'Capsules';
      case MedicationType.injection:
      case MedicationType.drops:
        return 'mL';
      default:
        return 'units';
    }
  }

  // Stepper
  static const int stepCount = 3;

  // Paddings and Spacings
  static const EdgeInsets formPadding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static const EdgeInsets summaryPadding = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets controlsPadding = EdgeInsets.symmetric(vertical: 32, horizontal: 16);
  static const double sectionSpacing = 16.0;
  static const double fieldSpacing = 16.0;

  // Styles
  static TextStyle summaryStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
  );

  // Decorations
  static InputDecoration textFieldDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    filled: true,
    fillColor: Colors.grey[100],
  );

  static InputDecoration get dropdownDecoration => InputDecoration(
    labelText: 'Type',
    helperText: 'Choose Medication Type',
    helperMaxLines: 2,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );

  static BoxDecoration appBarGradient(BuildContext context) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Button Style
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );

  // Icons
  static IconData getIconForForm(String form) {
    switch (form) {
      case 'Tablet':
        return Icons.tablet;
      case 'Capsule':
        return Icons.medication;
      case 'Injection':
        return Icons.medical_services;
      case 'Eye Drop':
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }
}