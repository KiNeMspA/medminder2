// lib/screens/medication_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../data/database.dart';
import '../services/drift_service.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  final Medication? medication;
  const MedicationScreen({super.key, this.medication});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedForm;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _strengthController.text = widget.medication!.concentration.toString();
      _unitController.text = widget.medication!.concentrationUnit;
      _quantityController.text = widget.medication!.stockQuantity.toString();
      _selectedForm = widget.medication!.form;
      _updateSummary();
    }
    _nameController.addListener(_updateSummary);
    _strengthController.addListener(_updateSummary);
    _unitController.addListener(_updateSummary);
    _quantityController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateSummary);
    _strengthController.removeListener(_updateSummary);
    _unitController.removeListener(_updateSummary);
    _quantityController.removeListener(_updateSummary);
    _nameController.dispose();
    _strengthController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    final name = _nameController.text.isEmpty ? 'Unnamed' : _nameController.text;
    final strength = double.tryParse(_strengthController.text) ?? 0;
    final unit = _unitController.text.isEmpty ? '' : _unitController.text;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final form = _selectedForm ?? 'Medication';
    final totalAmount = strength * quantity;

    setState(() {
      _summary = '$quantity x ${strength > 0 ? strength : ''}${unit.isNotEmpty ? unit : ''} $name ${form}s${totalAmount > 0 ? ' (${totalAmount}${unit} total)' : ''}';
    });
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final strength = double.parse(_strengthController.text);
      final unit = _unitController.text;
      final quantity = double.parse(_quantityController.text);

      final medication = MedicationsCompanion(
        name: drift.Value(name),
        concentration: drift.Value(strength),
        concentrationUnit: drift.Value(unit),
        stockQuantity: drift.Value(quantity),
        form: drift.Value(_selectedForm!),
      );

      ref.read(driftServiceProvider).addMedication(medication).then((_) {
        Navigator.pop(context);
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medication: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.medication?.name ?? 'Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedForm == null) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Medication Type',
                  helperText: 'Select the type of medication',
                ),
                items: Units.forms.map((form) => DropdownMenuItem(value: form, child: Text(form))).toList(),
                onChanged: (value) => setState(() {
                  _selectedForm = value;
                  _updateSummary();
                }),
                validator: (value) => value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Continue'),
              ),
            ] else ...[
              Text(
                _summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name',
                        helperText: "Enter the medication's name",
                      ),
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _strengthController,
                            decoration: const InputDecoration(
                              labelText: 'Strength',
                              helperText: 'Enter strength (mg, mcg, IU)',
                              helperMaxLines: 2,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) return 'Strength is required';
                              if (double.tryParse(value) == null) return 'Enter a valid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _unitController.text.isEmpty ? null : _unitController.text,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              helperText: ' ',
                            ),
                            items: Units.doseUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                            onChanged: (value) => setState(() => _unitController.text = value ?? ''),
                            validator: (value) => value == null ? 'Unit is required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Available Quantity',
                        helperText: 'How many ${_selectedForm!.toLowerCase()}s in stock',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Quantity is required';
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedForm,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        helperText: 'Confirm the medication type',
                      ),
                      items: Units.forms.map((form) => DropdownMenuItem(value: form, child: Text(form))).toList(),
                      onChanged: (value) => setState(() {
                        _selectedForm = value;
                        _updateSummary();
                      }),
                      validator: (value) => value == null ? 'Form is required' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveMedication,
                      child: const Text('Save Medication'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}