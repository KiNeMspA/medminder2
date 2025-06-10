import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/edit_field_dialog.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../constants/medication_ui_constants.dart';
import '../../dose/screens/dose_add_screen.dart';

class MedicationUtils {
  static Future<void> saveMedicationField(
      BuildContext context,
      WidgetRef ref,
      Medication med,
      String field,
      String value,
      ) async {
    try {
      final update = MedicationsCompanion(
        id: drift.Value(med.id),
        name: field == 'name' ? drift.Value(value) : drift.Value(med.name),
        concentration: field == 'concentration' ? drift.Value(double.parse(value)) : drift.Value(med.concentration),
        concentrationUnit: field == 'concentrationUnit' ? drift.Value(value) : drift.Value(med.concentrationUnit),
        stockQuantity: field == 'stockQuantity' ? drift.Value(double.parse(value)) : drift.Value(med.stockQuantity),
        form: drift.Value(med.form),
      );
      await ref.read(driftServiceProvider).updateMedication(update);
      ref.invalidate(medicationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Medication updated'),
          backgroundColor: MedicationUIConstants.secondaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  static void showEditDialog(
      BuildContext context,
      WidgetRef ref,
      Medication med,
      String field,
      String label,
      String initialValue, {
        List<String>? dropdownOptions,
      }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, _, __) => EditFieldDialog(
        title: 'Edit $label',
        label: label,
        initialValue: initialValue,
        keyboardType: field == 'name' ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value!.isEmpty) return '$label is required';
          if (field != 'name' && double.tryParse(value) == null) return 'Enter a valid number';
          return null;
        },
        dropdownOptions: dropdownOptions,
        onConfirm: (value) => saveMedicationField(context, ref, med, field, value),
      ),
    );
  }

  static void showTypeWarning(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, _, __) => StandardDialog(
        title: 'Cannot Edit Type',
        content: 'Medication type cannot be changed.',
        onConfirm: () => Navigator.pop(context),
        confirmText: 'OK',
        onCancel: null,
      ),
    );
  }

  static void showDeleteDialog(BuildContext context, WidgetRef ref, Medication med) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, _, __) => StandardDialog(
        title: 'Delete Medication',
        content: 'Are you sure you want to delete ${med.name}?',
        onConfirm: () async {
          await ref.read(driftServiceProvider).deleteMedication(med.id);
          ref.invalidate(medicationsProvider);
          Navigator.pop(context);
          Navigator.pop(context);
        },
        confirmText: 'Confirm',
      ),
    );
  }

  static Future<void> showAddScheduleDialog(BuildContext context, WidgetRef ref, int medicationId) async {
    final doses = await ref.read(driftServiceProvider).getDoses(medicationId);
    if (doses.isEmpty) {
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (context, anim1, anim2, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            child: FadeTransition(opacity: anim1, child: child),
          );
        },
        pageBuilder: (context, _, __) => StandardDialog(
          title: 'No Doses Available',
          content: 'You must add at least one dose before creating a schedule.',
          onConfirm: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DosesAddScreen(medicationId: medicationId)),
            );
          },
          onCancel: () => Navigator.pop(context),
          confirmText: 'Add Dose',
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/schedules/add', arguments: medicationId);
  }
}