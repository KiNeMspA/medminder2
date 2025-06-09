import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../dose/screens/dose_add_screen.dart';
import '../constants/medication_form_constants.dart';
import '../../../widgets/form_widgets.dart';

class MedicationOverviewScreen extends ConsumerWidget {
  final int medicationId;
  const MedicationOverviewScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsync = ref.watch(medicationsProvider);
    final dosesAsync = ref.watch(allDosesProvider);

    return medicationAsync.when(
      data: (meds) {
        final med = meds.firstWhere((m) => m.id == medicationId);
        return Scaffold(
          appBar: AppBar(
            title: Text(med.name),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: const Text('Name'),
                    subtitle: Text(med.name),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(context, ref, med, 'name', med.name),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: const Text('Concentration'),
                    subtitle: Text('${Utils.removeTrailingZeros(med.concentration)} ${med.concentrationUnit}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(context, ref, med, 'concentration', med.concentration.toString()),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: const Text('Stock Quantity'),
                    subtitle: Text('${Utils.removeTrailingZeros(med.stockQuantity)} ${med.form}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(context, ref, med, 'stockQuantity', med.stockQuantity.toString()),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: const Text('Form'),
                    subtitle: Text(med.form),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(context, ref, med, 'form', med.form),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Doses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                dosesAsync.when(
                  data: (doses) {
                    final medDoses = doses.where((dose) => dose.medicationId == medicationId).toList();
                    return medDoses.isEmpty
                        ? const Text('No doses added')
                        : Column(
                      children: medDoses.map((dose) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(dose.name ?? 'Unnamed'),
                          subtitle: Text('${Utils.removeTrailingZeros(dose.amount)} ${dose.unit}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => Navigator.pushNamed(context, '/doses/edit', arguments: dose.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Dose'),
                                      content: const Text('Are you sure you want to delete this dose?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
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
                      )).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Dose'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DosesAddScreen(medicationId: medicationId)),
                  ).then((_) => ref.invalidate(allDosesProvider)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Add Schedule'),
                  onPressed: () async {
                    final doses = await ref.read(driftServiceProvider).getDoses(medicationId);
                    if (doses.isEmpty) {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('No Doses Available'),
                          content: const Text('You must add at least one dose before creating a schedule.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DosesAddScreen(medicationId: medicationId)),
                                );
                              },
                              child: const Text('Add Dose'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    Navigator.pushNamed(context, '/schedules/add', arguments: medicationId);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Future<void> _editField(BuildContext context, WidgetRef ref, Medication med, String field, String initialValue) async {
    final newValue = await FormWidgets.showInputDialog(
      context: context,
      title: 'Edit $field',
      initialValue: initialValue,
      label: field,
      keyboardType: field == 'concentration' || field == 'stockQuantity' ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? '$field is required' : null,
    );
    if (newValue != null) {
      final update = MedicationsCompanion(
        id: drift.Value(med.id),
        name: field == 'name' ? drift.Value(newValue) : drift.Value(med.name),
        concentration: field == 'concentration' ? drift.Value(double.parse(newValue)) : drift.Value(med.concentration),
        concentrationUnit: drift.Value(med.concentrationUnit),
        stockQuantity: field == 'stockQuantity' ? drift.Value(double.parse(newValue)) : drift.Value(med.stockQuantity),
        form: field == 'form' ? drift.Value(newValue) : drift.Value(med.form),
      );
      await ref.read(driftServiceProvider).updateMedication(update);
      ref.invalidate(medicationsProvider);
    }
  }
}