// lib/screens/dose_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dose/dose_form.dart';
import '../data/database.dart';
import '../services/drift_service.dart';

class DoseScreen extends ConsumerStatefulWidget {
  final Medication medication;
  const DoseScreen({super.key, required this.medication});

  @override
  _DoseScreenState createState() => _DoseScreenState();
}

class _DoseScreenState extends ConsumerState<DoseScreen> {
  Dose? _selectedDose;

  void _clearForm() {
    setState(() => _selectedDose = null);
  }

  void _editDose(Dose dose) {
    setState(() => _selectedDose = dose);
  }

  void _dismissKeyboard() {
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(dosesProvider(widget.medication.id));

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(title: Text('Doses for ${widget.medication.name}')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DoseForm(
                medication: widget.medication,
                onEditDose: _editDose,
                onClearForm: _clearForm,
                onDismissKeyboard: _dismissKeyboard,
              ),
            ),
            Expanded(
              child: dosesAsync.when(
                data: (doses) => ListView.builder(
                  itemCount: doses.length,
                  itemBuilder: (context, index) {
                    final dose = doses[index];
                    return ListTile(
                      title: Text('${dose.amount} ${dose.unit}'),
                      subtitle: dose.weight != 0.0 ? Text('Weight: ${dose.weight} kg') : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this dose?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(driftServiceProvider).deleteDose(dose.id).then((_) {
                                      ref.invalidate(dosesProvider(widget.medication.id));
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () => _editDose(dose),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}