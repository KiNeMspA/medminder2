import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../../../common/widgets/edit_field_dialog.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../dose/screens/dose_add_screen.dart';
import '../constants/medication_form_constants.dart';

class MedicationOverviewScreen extends ConsumerWidget {
  final int medicationId;

  const MedicationOverviewScreen({super.key, required this.medicationId});

  Future<void> _saveMedicationField(BuildContext context,
      WidgetRef ref,
      Medication med,
      String field,
      String value,) async {
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
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .error,
        ),
      );
    }
  }

  void _showEditDialog(BuildContext context,
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
      pageBuilder: (context, _, __) =>
          EditFieldDialog(
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
            onConfirm: (value) => _saveMedicationField(context, ref, med, field, value),
          ),
    );
  }

  void _showTypeWarning(BuildContext context) {
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
      pageBuilder: (context, _, __) =>
          StandardDialog(
            title: 'Cannot Edit Type',
            content: 'Medication type cannot be changed.',
            onConfirm: () => Navigator.pop(context),
            confirmText: 'OK',
            onCancel: null,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsync = ref.watch(medicationsProvider);
    final dosesAsync = ref.watch(allDosesProvider);
    final schedulesAsync = ref.watch(schedulesProvider);

    return medicationAsync.when(
      data: (meds) {
        final med = meds.firstWhere((m) => m.id == medicationId);
        final qtyNum = med.stockQuantity;
        final medQtyUnit = med.form == 'Tablet'
            ? qtyNum > 1
            ? 'Tablets'
            : 'Tablet'
            : med.form == 'Capsule'
            ? qtyNum > 1
            ? 'Capsules'
            : 'Capsule'
            : 'mL';
        final type = MedicationMatrix.formToType(med.form);
        final subType = MedicationFormConstants.subTypes[type]?.contains(med.form) ?? false
            ? med.form
            : MedicationFormConstants.subTypes[type]?.first;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              med.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme
                        .of(context)
                        .colorScheme
                        .primary,
                    Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
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
                      pageBuilder: (context, _, __) =>
                          StandardDialog(
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
                    ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 300),
                  childAnimationBuilder: (widget) =>
                      SlideAnimation(
                        verticalOffset: 50,
                        child: widget,
                      ),
                  children: [
                    // Medication Details
                    const Text(
                      'Medication Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          gradient: LinearGradient(
                            colors: [Colors.grey[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildListTile(
                                context,
                                title: 'Name: ${med.name}',
                                trailing: const Icon(Icons.edit, size: 24, color: Colors.blue),
                                onTap: () => _showEditDialog(context, ref, med, 'name', 'Medication Name', med.name),
                              ),
                              const Divider(height: 8),
                              _buildListTile(
                                context,
                                title: 'Type: ${med.form}',
                                trailing: const Icon(Icons.lock, size: 24, color: Colors.grey),
                                onTap: () => _showTypeWarning(context),
                              ),
                              const Divider(height: 8),
                              _buildListTile(
                                context,
                                title:
                                'Strength: ${Utils.removeTrailingZeros(med.concentration)}${med
                                    .concentrationUnit} per ${med.form == 'Tablet' ? 'Tablet' : med.form == 'Capsule'
                                    ? 'Capsule'
                                    : 'mL'}',
                                trailing: const Icon(Icons.edit, size: 24, color: Colors.blue),
                                onTap: () =>
                                    _showEditDialog(context, ref, med, 'concentration', 'Concentration',
                                        med.concentration.toString()),
                              ),
                              const Divider(height: 8),
                              _buildListTile(
                                context,
                                title: 'Unit: ${med.concentrationUnit}',
                                trailing: const Icon(Icons.edit, size: 24, color: Colors.blue),
                                onTap: () =>
                                    _showEditDialog(
                                      context,
                                      ref,
                                      med,
                                      'concentrationUnit',
                                      'Concentration Unit',
                                      med.concentrationUnit,
                                      dropdownOptions: MedicationFormConstants.getConcentrationUnits(type, subType),
                                    ),
                              ),
                              const Divider(height: 8),
                              _buildListTile(
                                context,
                                title: 'Stock: ${Utils.removeTrailingZeros(med.stockQuantity)} $medQtyUnit',
                                trailing: const Icon(Icons.edit, size: 24, color: Colors.blue),
                                onTap: () =>
                                    _showEditDialog(context, ref, med, 'stockQuantity', 'Stock Quantity',
                                        med.stockQuantity.toString()),
                              ),
                              const Divider(height: 8),
                              _buildListTile(
                                context,
                                title:
                                'Total: ${Utils.removeTrailingZeros(med.concentration * med.stockQuantity)}${med
                                    .concentrationUnit}',
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Doses
                    const Text(
                      'Doses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    dosesAsync.when(
                      data: (doses) {
                        final medDoses = doses.where((dose) => dose.medicationId == medicationId).toList();
                        return medDoses.isEmpty
                            ? const Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No doses added', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ),
                        )
                            : Column(
                          children: medDoses
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final dose = entry.value;
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20,
                                child: Card(
                                  elevation: 2,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(16))),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      dose.name ?? 'Unnamed',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      '${Utils.removeTrailingZeros(dose.amount)} ${dose.unit}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () =>
                                              Navigator.pushNamed(context, '/doses/edit', arguments: dose.id),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) =>
                                                  StandardDialog(
                                                    title: 'Delete Dose',
                                                    content: 'Are you sure you want to delete this dose?',
                                                    onConfirm: () => Navigator.pop(context, true),
                                                    onCancel: () => Navigator.pop(context, false),
                                                  ),
                                            );
                                            if (confirm == true) {
                                              await ref.read(driftServiceProvider).deleteDose(dose.id);
                                              ref.invalidate(allDosesProvider);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () => Navigator.pushNamed(context, '/doses/edit', arguments: dose.id),
                                  ),
                                ),
                              )
                              ,
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Text('Error: $e', style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .error)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Dose', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DosesAddScreen(medicationId: medicationId)),
                          ).then((_) => ref.invalidate(allDosesProvider)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Upcoming Doses
                    const Text(
                      'Upcoming Doses',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    schedulesAsync.when(
                      data: (schedules) {
                        final upcoming = schedules
                            .where((s) => s.medicationId == medicationId && s.time.isAfter(DateTime.now()))
                            .take(3)
                            .toList();
                        return upcoming.isEmpty
                            ? const Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No upcoming doses', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ),
                        )
                            : Column(
                          children: upcoming
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final schedule = entry.value;
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20,
                                child: Card(
                                  elevation: 2,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(16))),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      schedule.medicationName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      'Time: ${DateFormat.jm().format(schedule.time)}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    trailing: const Icon(Icons.schedule, color: Colors.teal),
                                  ),
                                ),
                            )
                            ,
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Text('Error: $e', style: TextStyle(color: Theme
                              .of(context)
                              .colorScheme
                              .error)),
                    ),
                    const SizedBox(height: 16),
                    // Schedule Calendar
                    const Text(
                      'Schedule Calendar',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: Text(
                            'Interactive calendar coming soon...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stock Management
                    const Text(
                      'Stock Management',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildListTile(
                              context,
                              title: 'Refill Stock',
                              trailing: const Icon(Icons.add_circle, size: 24, color: Colors.green),
                              onTap: () =>
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
                                    pageBuilder: (context, _, __) =>
                                        EditFieldDialog(
                                          title: 'Refill Stock',
                                          label: 'Additional Stock',
                                          initialValue: '0',
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: (value) {
                                            if (value!.isEmpty) return 'Amount is required';
                                            if (double.tryParse(value) == null) return 'Enter a valid number';
                                            return null;
                                          },
                                          onConfirm: (value) {
                                            final newStock = med.stockQuantity + double.parse(value);
                                            _saveMedicationField(
                                                context, ref, med, 'stockQuantity', newStock.toString());
                                          },
                                        ),
                                  ),
                            ),
                            const Divider(height: 8),
                            _buildListTile(
                              context,
                              title: 'Stock Estimated Run Out',
                              subtitle: 'Calculation coming soon...',
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              subtitleStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dose History
                    const Text(
                      'Dose History',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Dose history list coming soon...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Schedule
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: () async {
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
                            pageBuilder: (context, _, __) =>
                                StandardDialog(
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          ,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        title,
        style: textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: subtitleStyle ?? const TextStyle(fontSize: 14, color: Colors.grey),
      )
          : null,
      trailing: trailing,
      onTap: onTap,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      tileColor: Colors.white.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
    );
  }
}