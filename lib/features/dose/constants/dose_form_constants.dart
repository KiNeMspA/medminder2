import 'package:flutter/material.dart';

class DoseFormConstants {
  // Strings
  static const String unnamedDose = 'Unnamed Dose';
  static const String noDoseSpecified = 'No dose specified';
  static const String noDosesMessage = 'No doses scheduled';
  static const String defaultTabletUnit = 'mg';
  static const String tabletUnit = 'Tablet';
  static const String tabletCountLabel = 'Number of Tablets';
  static const String concentrationLabel = 'Concentration';
  static const String doseNameLabel = 'Dose Name';
  static const String notSet = 'Not set';
  static const String editTabletCountTitle = 'Edit Tablet Count';
  static const String editConcentrationTitle = 'Edit Concentration';
  static const String editDoseNameTitle = 'Edit Dose Name';
  static const String tabletCountHelper = 'Enter the number of tablets (e.g., 2)';
  static const String concentrationHelperTablet = 'Enter the total active compound (e.g., 200 mg)';
  static const String concentrationHelperNonTablet = 'Enter the dose amount (e.g., 1 mL)';
  static const String doseNameHelper = 'Enter a name for the dose (e.g., Ibuprofen Tablet)';
  static const String doseNameRequired = 'Name is required';
  static const String invalidRangeMessage = 'Dose value out of valid range (0.01–999)';
  static const String duplicateDoseMessage = 'A dose with this amount and unit already exists';
  static const String doseSavedMessage = 'Dose saved';
  static const String saveDoseButton = 'Save Dose';
  static const String updateDoseButton = 'Update Dose';
  static const String deleteDialogTitle = 'Confirm Deletion';
  static const String deleteDialogContent = 'Are you sure you want to delete this dose?';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';

  static String screenTitle(String medicationName) => 'Doses for $medicationName';

  static String exceedStockMessage(double stock) => 'Dose exceeds available stock ($stock tablets)';

  static String errorSavingDose(Object error) => 'Error saving dose: $error';

  static String errorLoadingDoses(Object error) => 'Error: $error';

  // Paddings and Spacings
  static const EdgeInsets formPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const double sectionSpacing = 24.0;
  static const double fieldSpacing = 16.0;

  // Card Styling
  static const double cardElevation = 2.0;
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Text Styles
  static TextStyle nameStyle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary);

  static TextStyle summaryStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black54, fontSize: 14);

  static TextStyle buttonTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white);

  // Button Style
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );

  // AppBar Gradient
  static BoxDecoration appBarGradient(BuildContext context) => BoxDecoration(
    gradient: LinearGradient(
      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}