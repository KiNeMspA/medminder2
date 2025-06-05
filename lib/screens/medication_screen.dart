import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
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
  final _concentrationController = TextEditingController(); // Changed from _strengthController
  final _unitController = TextEditingController(text: 'mg'); // Default to mg
  final _stockController = TextEditingController(); // Changed from _quantityController
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
      _stockController.text = med.stockQuantity.toString();
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
    _stockController.addListener(_updateSummary);
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
    _stockController
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
    final stock = double.tryParse(_stockController.text) ?? 0;
    final form = _selectedForm ?? 'Medication';
    final total = concentration * stock;
    setState(() {
      _summary = '$stock x ${concentration > 0 ? concentration : ''}$unit $name $form${total > 0 ? ' (${total}$unit total)' : ''}';
    });
  }

  void _saveMedication() {
    if (!_formKey.currentState!.validate()) return;

    final concentration = double.parse(_concentrationController.text);
    final stock = double.parse(_stockController.text);

    if (!MedicationMatrix.isValidValue(_selectedType!, concentration, 'concentration') ||
        !MedicationMatrix.isValidValue(_selectedType!, stock, 'quantity')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Values out of valid range (0.01–999)')),
      );
      return;
    }

    final medication = MedicationsCompanion(
      name: drift.Value(_nameController.text),
      concentration: drift.Value(concentration),
      concentrationUnit: drift.Value(_unitController.text),
      stockQuantity: drift.Value(stock),
      form: drift.Value(_selectedForm!),
    );

    ref.read(driftServiceProvider).addMedication(medication).then((_) {
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.medication?.name ?? 'Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedForm == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormWidgets.buildDropdown(
              label: 'Medication Type',
              helperText: 'Choose whether the medication is a tablet or injection',
              items: ['Tablet', 'Injection'], // Limited to Tablet and Injection
              value: _selectedForm,
              onChanged: (value) => setState(() {
                _selectedForm = value;
                _selectedType = MedicationType.values.firstWhere(
                      (type) => type.toString().split('.').last == value!.toLowerCase().replaceAll(' ', ''),
                  orElse: () => MedicationType.tablet,
                );
                _unitController.text = 'mg';
                _updateSummary();
              }),
              validator: (value) => value == null ? 'Please select a type' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Continue'),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_summary.isNotEmpty)
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
                  FormWidgets.buildTextField(
                    controller: _nameController,
                    label: 'Medication Name',
                    helperText: 'Enter the full name of the medication (e.g., Ibuprofen)',
                    validator: (value) => value!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: FormWidgets.buildTextField(
                          controller: _concentrationController,
                          label: 'Concentration',
                          helperText: 'Enter the active compound amount (e.g., 5mg, 10g)',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                          value!.isEmpty ? 'Concentration is required' : double.tryParse(value) == null ? 'Enter a valid number' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: FormWidgets.buildDropdown(
                          label: 'Unit',
                          helperText: 'Unit (e.g., mg)',
                          items: MedicationMatrix.getConcentrationUnits(_selectedType!),
                          value: _unitController.text.isEmpty ? 'mg' : _unitController.text,
                          onChanged: (value) => setState(() => _unitController.text = value ?? 'mg'),
                          validator: (value) => value == null ? 'Unit is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FormWidgets.buildTextField(
                    controller: _stockController,
                    label: 'Stock Quantity',
                    helperText: 'Enter the number of tablets in stock',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Stock quantity is required' : double.tryParse(value) == null ? 'Enter a valid number' : null,
                  ),
                  const SizedBox(height: 24),
                  FormWidgets.buildDropdown(
                    label: 'Medication Type',
                    helperText: 'Confirm medication type',
                    items: ['Tablet', 'Injection'],
                    value: _selectedForm,
                    onChanged: (value) => setState(() {
                      _selectedForm = value;
                      _selectedType = MedicationType.values.firstWhere(
                            (type) => type.toString().split('.').last == value!.toLowerCase().replaceAll(' ', ''),
                        orElse: () => MedicationType.tablet,
                      );
                      _unitController.text = 'mg';
                      _updateSummary();
                    }),
                    validator: (value) => value == null ? 'Medication type is required' : null,
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
        ),
      ),
    );
  }
}