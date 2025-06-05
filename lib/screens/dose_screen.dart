// lib/screens/dose_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dose/dose_form.dart';
import '../core/calculations.dart';
import '../data/database.dart';
import '../services/drift_service.dart';
import 'schedule_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(dosesProvider(widget.medication.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Doses for ${widget.medication.name}'),
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
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DoseForm(
              medication: widget.medication,
              onEditDose: _editDose,
              onClearForm: _clearForm,
              selectedDose: _selectedDose,
            ),
            const Divider(height: 1),
            dosesAsync.when(
              data: (doses) => doses.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No doses scheduled'),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doses.length,
                itemBuilder: (context, index) {
                  final dose = doses[index];
                  final isSelected = _selectedDose?.id == dose.id;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    color: isSelected ? Colors.grey[100] : null,
                    child: ListTile(
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: dose.name ?? 'Unnamed',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            TextSpan(
                              text: ' - ${dose.amount} ${dose.unit == 'Tablet' ? 'Tablet${dose.amount == 1 ? '' : 's'}' : dose.unit} '
                                  '${dose.unit == 'Tablet' ? '(${MedCalculations.formatNumber(dose.amount * widget.medication.concentration)} ${widget.medication.concentrationUnit})' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.schedule, color: Colors.blue),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScheduleScreen(
                                  dose: dose,
                                  medication: widget.medication,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
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
                        ],
                      ),
                      onTap: () => _editDose(dose),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}