// lib/features/schedule/constants/schedule_form_constants.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/formatters.dart'; // Add import
import '../../../data/database.dart';

class ScheduleFormConstants {
  // Strings
  static const String defaultName = 'Unnamed Schedule';
  static const String defaultFrequency = 'Daily';
  static const String dailyFrequency = 'Daily';
  static const String weeklyFrequency = 'Weekly';
  static const String nameLabel = 'Schedule Name';
  static const String frequencyLabel = 'Frequency';
  static const String daysLabel = 'Days';
  static const String doseLabel = 'Dose (Optional)';
  static const String doseSelectLabel = 'Select Dose';
  static const String noDose = 'None';
  static const String nameHelper = 'Enter a name for the schedule (e.g., Morning Dose)';
  static const String nameRequiredMessage = 'Schedule Name is required';
  static const String frequencyRequiredMessage = 'Frequency is required';
  static const String noDaysSelectedMessage = 'Please select at least one day';
  static const String scheduleSavedMessage = 'Schedule saved';
  static const String saveButton = 'Save Schedule';
  static const List<String> frequencies = ['Daily', 'Weekly'];
  static const List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String screenTitle(String medicationName) => 'Schedule for $medicationName';
  static String timeLabel(TimeOfDay time) => 'Time: ${DateFormat.jm().format(DateTime(2023, 1, 1, time.hour, time.minute))}';
  static String notificationTitle(String medicationName) => 'Medication Reminder: $medicationName';
  static String notificationBodyWithDose(double amount, String unit, String name) =>
      'Time to take ${Utils.removeTrailingZeros(amount)} $unit ($name)';
  static String notificationBodyWithoutDose(String name) => 'Schedule: $name';
  static String doseDisplay(Dose dose) =>
      '${Utils.removeTrailingZeros(dose.amount)} ${dose.unit == 'Tablet' ? 'Tablet${dose.amount == 1 ? '' : 's'}' : dose.unit} (${dose.name ?? 'Unnamed'})';
  static String errorSavingMessage(Object error) => 'Error saving schedule: $error';

  // Paddings and Spacings
  static const EdgeInsets formPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets cardContentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const double fieldSpacing = 16.0;
  static const double buttonSpacing = 32.0;
  static const double innerSpacing = 8.0;

  // Card Styling
  static const double cardElevation = 2.0;
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Styles
  static TextStyle sectionTitleStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.copyWith(
    fontWeight: FontWeight.bold,
  );

  static TextStyle buttonTextStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!.copyWith(
    color: Colors.white,
  );

  // Decorations
  static InputDecoration textFieldDecoration(String label, String? helperText) => InputDecoration(
    labelText: label,
    helperText: helperText,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static InputDecoration dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    helperText: label.contains('Dose') ? 'Choose a dose for this schedule (required)' : null,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Button Style
  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );

  // AppBar Gradient
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
}