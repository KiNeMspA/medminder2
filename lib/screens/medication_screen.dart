// lib/screens/medication_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/medication_matrix.dart';
import '../data/database.dart';
import '../services/drift_service.dart';
import '../../widgets/form_widgets.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  final Medication? medication;
  const MedicationScreen({super.key, this.medication});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _unitController = TextEditingController(text: 'mg');
  final _quantityController = TextEditingController();
  String? _selectedForm;
  MedicationType? _selectedType;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      final med = widget.medication!;
      _nameController.text = med.name;
      _concentrationController.text = med.concentration.toString();
      _unitController.text = med.concentrationUnit.isEmpty ? 'mg' : med.concentrationUnit;
      _quantityController.text = med.stockQuantity.toString();
      _selectedForm = med.form;
      _selectedType = MedicationType.values.firstWhere(
            (type) => type.toString().split('.').last == med.form.toLowerCase().replaceAll(' ', ''),
        orElse: () => MedicationType.tablet,
      );
      _updateSummary();
    }
    _nameController.addListener(_updateSummary);
    _concentrationController.addListener(_updateSummary);
    _unitController.addListener(_updateSummary);
    _quantityController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_updateSummary)
      ..dispose();
    _concentrationController
      ..removeListener(_updateSummary)
      ..dispose();
    _unitController
      ..removeListener(_updateSummary)
      ..dispose();
    _quantityController
      ..removeListener(_updateSummary)
      ..dispose();
    super.dispose();
  }

  void _updateSummary() {
    if (_nameController.text.isEmpty) {
      setState(() => _summary = '');
      return;
    }
    final name = _nameController.text;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    final unit = _unitController.text;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final form = _selectedForm ?? 'Medication';
    final total = concentration * quantity;
    setState(() {
      _summary = '$quantity x ${concentration > 0 ? concentration : ''}$unit $name $form${total > 0 ? ' (${total}$unit total)' : ''}';
    });
  }

  Future<bool> _hasDosesOrSchedules() async {
    if (widget.medication == null) return false;
    final doses = await ref.read(driftServiceProvider).getDoses(widget.medication!.id);
    if (doses.isNotEmpty) return true;
    for (final dose in doses) {
      final schedules = await ref.read(driftServiceProvider).getSchedules(dose.id);
      if (schedules.isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> _isNameUnique(String name) async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    return !medications.any((med) => med.name.toLowerCase() == name.toLowerCase() && (widget.medication == null || med.id != widget.medication!.id));
  }

  void _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final concentration = double.parse(_concentrationController.text);
    final quantity = double.parse(_quantityController.text);

    if (!MedicationMatrix.isValidValue(_selectedType!, concentration, 'concentration') ||
        !MedicationMatrix.isValidValue(_selectedType!, quantity, 'quantity')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Values out of valid range (0.01–999)')),
      );
      return;
    }

    if (!(await _isNameUnique(name))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A medication with this name already exists')),
      );
      return;
    }

    final medication = MedicationsCompanion(
      id: widget.medication != null ? drift.Value(widget.medication!.id) : const drift.Value.absent(),
      name: drift.Value(name),
      concentration: drift.Value(concentration),
      concentrationUnit: drift.Value(_unitController.text),
      stockQuantity: drift.Value(quantity),
      form: drift.Value(_selectedForm!),
    );

    if (widget.medication != null && await _hasDosesOrSchedules()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Editing this medication may impact existing doses or schedules. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performSave(medication);
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
    } else {
      _performSave(medication);
    }
  }

  void _performSave(MedicationsCompanion medication) {
    ref.read(driftServiceProvider).addMedication(medication).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication saved')),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    });
  }

  Future<void> _editField({
    required String title,
    required String label,
    required TextEditingController controller,
    String? helperText,
    TextInputType? keyboardType,
  }) async {
    final result = await FormWidgets.showInputDialog(
      context: context,
      title: title,
      initialValue: controller.text,
      label: label,
      helperText: helperText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty
          ? '$label is required'
          : keyboardType == TextInputType.number && double.tryParse(value) == null
          ? 'Enter a valid number'
          : null,
    );
    if (result != null) {
      setState(() {
        controller.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication?.name ?? 'Add Medication'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedForm == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Medication Type',
                    helperText: 'Choose whether the medication is a tablet or injection',
                    border: InputBorder.none,
                  ),
                  value: _selectedForm,
                  items: ['Tablet', 'Injection']
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedForm = value;
                      _selectedType = MedicationType.values.firstWhere(
                            (type) => type.toString().split('.').last == value!.toLowerCase().replaceAll(' ', ''),
                        orElse: () => MedicationType.tablet,
                      );
                      _unitController.text = 'mg';
                      _updateSummary();
                    });
                  },
                  validator: (value) => value == null ? 'Medication Type is required' : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_summary.isNotEmpty)
              Text(
                _summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        'Medication Name: ${_nameController.text.isEmpty ? 'Not set' : _nameController.text}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () => _editField(
                        title: 'Edit Medication Name',
                        label: 'Medication Name',
                        controller: _nameController,
                        helperText: 'Enter the full name of the medication (e.g., Ibuprofen)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        'Concentration: ${_concentrationController.text.isEmpty ? 'Not set' : _concentrationController.text} ${_unitController.text}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () => FormWidgets.showInputDialog(
                        context: context,
                        title: 'Edit Concentration',
                        initialValue: _concentrationController.text,
                        label: 'Concentration',
                        helperText: 'Enter the active compound amount (e.g., 100)',
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Concentration is required'
                            : double.tryParse(value) == null
                            ? 'Enter a valid number'
                            : null,
                        dropdownItems: MedicationMatrix.getConcentrationUnits(_selectedType!).toSet().toList(),
                        dropdownValue: _unitController.text.isNotEmpty ? _unitController.text : null,
                        onDropdownChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _unitController.text = value;
                              _updateSummary();
                            });
                          }
                        },
                      ).then((result) {
                        if (result != null) {
                          setState(() {
                            _concentrationController.text = result;
                          });
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        'Quantity: ${_quantityController.text.isEmpty ? 'Not set' : _quantityController.text}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () => _editField(
                        title: 'Edit Quantity',
                        label: 'Quantity',
                        controller: _quantityController,
                        helperText: 'Enter the number of tablets in stock',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Medication Type',
                          helperText: 'Confirm the medication is a tablet or injection',
                          border: InputBorder.none,
                        ),
                        value: _selectedForm,
                        items: ['Tablet', 'Injection']
                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedForm = value;
                            _selectedType = MedicationType.values.firstWhere(
                                  (type) => type.toString().split('.').last == value!.toLowerCase().replaceAll(' ', ''),
                              orElse: () => MedicationType.tablet,
                            );
                            _unitController.text = 'mg';
                            _updateSummary();
                          });
                        },
                        validator: (value) => value == null ? 'Medication Type is required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveMedication,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save Medication',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}