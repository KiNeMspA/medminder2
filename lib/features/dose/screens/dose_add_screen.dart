import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../medication/constants/medication_form_constants.dart';

class DosesAddScreen extends ConsumerStatefulWidget {
  const DosesAddScreen({super.key});

  @override
  ConsumerState<DosesAddScreen> createState() => _DosesAddScreenState();
}

class _DosesAddScreenState extends ConsumerState<DosesAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '0');
  int? _selectedMedicationId;
  String? _selectedMedicationName;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _currentStep = 0;
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _amountController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    final meds = await ref.read(driftServiceProvider).getMedications();
    setState(() {
      _medications = meds;
    });
  }

  String get _summary {
    if (_selectedMedicationName == null || _amountController.text.isEmpty) return '';
    final amount = double.tryParse(_amountController.text) ?? 0;
    return 'Dose: $amount for $_selectedMedicationName at ${_selectedTime.format(context)}';
  }

  void _updateSummary() {
    setState(() {});
  }

  void _incrementAmount() {
    final current = double.tryParse(_amountController.text) ?? 0;
    _amountController.text = (current + 1).toInt().toString();
  }

  void _decrementAmount() {
    final current = double.tryParse(_amountController.text) ?? 0;
    if (current > 0) {
      _amountController.text = (current - 1).toInt().toString();
    }
  }

  void _saveDose() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selectedMedicationId == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medication and enter a valid amount')),
      );
      return;
    }

    final medication = _medications.firstWhere((med) => med.id == _selectedMedicationId);
    final type = MedicationMatrix.formToType(medication.form);
    if (!MedicationMatrix.isValidValue(type, amount, 'quantity')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount out of valid range (0.01–999)')),
      );
      return;
    }

    final dose = DosesCompanion(
      medicationId: drift.Value(_selectedMedicationId!),
      medicationName: drift.Value(_selectedMedicationName!),
      amount: drift.Value(amount),
      unit: drift.Value(medication.form == 'Tablet' || medication.form == 'Capsule' ? 'Tablet' : 'mL'),
      time: drift.Value(DateTime.now().copyWith(hour: _selectedTime.hour, minute: _selectedTime.minute)),
    );

    try {
      await ref.read(driftServiceProvider).addDose(dose);
      ref.invalidate(allDosesProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose added')),
      );
    } catch (e, stack) {
      debugPrint('Save error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding dose: $e')),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Select Medication'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medications.map((med) {
                return ChoiceChip(
                  label: Text(med.name),
                  selected: _selectedMedicationId == med.id,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMedicationId = med.id;
                        _selectedMedicationName = med.name;
                        _updateSummary();
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        isActive: _currentStep == 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Dose Amount'),
        content: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                decoration: MedicationFormConstants.textFieldDecoration('Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty || double.tryParse(value) == null ? 'Valid number required' : null,
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _incrementAmount,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: _decrementAmount,
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Dose Time'),
        content: ElevatedButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
                _updateSummary();
              });
            }
          },
          child: Text('Select Time: ${_selectedTime.format(context)}'),
        ),
        isActive: _currentStep == 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Confirm'),
        content: Text(_summary.isEmpty ? 'Please complete all steps' : _summary),
        isActive: _currentStep == 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dose'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_summary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _summary,
                        style: MedicationFormConstants.summaryStyle(context).copyWith(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: MedicationFormConstants.sectionSpacing),
                  Stepper(
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep == 0 && _selectedMedicationId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a medication')),
                        );
                        return;
                      }
                      if (_currentStep == 1 && _amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter an amount')),
                        );
                        return;
                      }
                      if (_currentStep < _buildSteps().length - 1) {
                        setState(() => _currentStep += 1);
                      } else {
                        _saveDose();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    steps: _buildSteps(),
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (details.onStepCancel != null)
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Back'),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: MedicationFormConstants.buttonStyle,
                              child: Text(_currentStep == _buildSteps().length - 1 ? 'Save' : 'Next'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}