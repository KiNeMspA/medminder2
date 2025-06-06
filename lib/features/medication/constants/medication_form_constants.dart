// lib/features/medication/constants/medication_form_constants.dart
import 'package:flutter/material.dart';

class MedicationFormConstants {
  // Strings
  static const String addMedicationTitle = 'Add Medication';
  static const String selectTypeTitle = 'Select Medication Type';
  static const String defaultUnit = 'mg';
  static const String defaultForm = 'Medication';
  static const String nameLabel = 'Medication Name';
  static const String concentrationLabel = 'Concentration';
  static const String quantityLabel = 'Quantity';
  static const String unitsLabel = 'units';
  static const String nameHelper = 'e.g., Ibuprofen';
  static const String concentrationHelper = 'e.g., 100 mg';
  static const String quantityHelper = 'Stock amount';
  static const String nameRequiredMessage = 'Medication Name is required';
  static const String concentrationRequiredMessage = 'Concentration is required';
  static const String quantityRequiredMessage = 'Quantity is required';
  static const String invalidNumberMessage = 'Enter a valid number';
  static const String typeRequiredMessage = 'Medication Type is required';
  static const String selectTypeMessage = 'Please select a medication type';
  static const String invalidRangeMessage = 'Values out of valid range (0.01–999)';
  static const String duplicateNameMessage = 'A medication with this name already exists';
  static const String medicationSavedMessage = 'Medication saved';
  static const String warningTitle = 'Warning';
  static const String warningContent = 'Editing this medication may impact existing doses or schedules. Do you want to proceed?';
  static const String cancelButton = 'Cancel';
  static const String proceedButton = 'Proceed';
  static const String continueButton = 'Continue';
  static const String saveButton = 'Save Medication';
  static const List<String> medicationTypes = ['Tablet', 'Injection'];

  static String errorSavingMessage(Object error) => 'Error: $error';

  // Paddings and Spacings
  static const EdgeInsets formPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const double sectionSpacing = 16.0;
  static const double fieldSpacing = 16.0;
  static const double buttonSpacing = 32.0;

  // Card Styling
  static const double cardElevation = 2.0;
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Styles
  static const TextStyle titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  static TextStyle summaryStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
  );

  // Decorations
  static InputDecoration textFieldDecoration(String label, String? helperText) => InputDecoration(
    labelText: label,
    helperText: helperText,
    helperMaxLines: 2, // Allow wrapping for helper text
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );

  static InputDecoration get dropdownDecoration => InputDecoration(
    labelText: 'Medication Type',
    helperText: 'Choose Medication Type',
    helperMaxLines: 2, // Allow wrapping for helper text
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  );

  // Button Style
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
}