// lib/features/medication/screens/add_medication_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../data/database.dart'; // Add this import
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../widgets/medication_form_card.dart';
import '../widgets/medication_form_field.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState(); // Fix return type
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedForm;
  MedicationType? _selectedType;
  String _unit = MedicationFormConstants.defaultUnit;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _concentrationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _nameController.addListener(_updateSummary);
    _concentrationController.addListener(_updateSummary);
    _quantityController.addListener(_updateSummary);
  }

  void _updateSummary() {
    if (_nameController.text.isEmpty || _selectedForm == null) {
      setState(() => _summary = '');
      return;
    }
    final name = _nameController.text;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final total = concentration * quantity;
    setState(() {
      _summary = '$quantity x ${concentration > 0 ? concentration : ''}$_unit $name $_selectedForm${total > 0 ? ' (${total}$_unit total)' : ''}';
    });
  }

  Future<bool> _isNameUnique(String name) async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    return !medications.any((med) => med.name.toLowerCase() == name.toLowerCase());
  }

  void _incrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toString();
  }

  void _decrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
  }

  void _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final concentration = double.parse(_concentrationController.text);
    final quantity = double.parse(_quantityController.text);

    if (!MedicationMatrix.isValidValue(_selectedType!, concentration, 'concentration') ||
        !MedicationMatrix.isValidValue(_selectedType!, quantity, 'quantity')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MedicationFormConstants.invalidRangeMessage)),
      );
      return;
    }

    if (!(await _isNameUnique(name))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MedicationFormConstants.duplicateNameMessage)),
      );
      return;
    }

    final medication = MedicationsCompanion(
      name: drift.Value(name),
      concentration: drift.Value(concentration),
      concentrationUnit: drift.Value(_unit),
      stockQuantity: drift.Value(quantity),
      form: drift.Value(_selectedForm!),
    );

    ref.read(driftServiceProvider).addMedication(medication).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MedicationFormConstants.medicationSavedMessage)),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MedicationFormConstants.errorSavingMessage(e))),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MedicationFormConstants.addMedicationTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: MedicationFormConstants.formPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedicationFormCard(
                    child: DropdownButtonFormField<String>(
                      decoration: MedicationFormConstants.dropdownDecoration.copyWith(
                        labelText: null,
                        hint: const Text('Select Medication Type'),
                      ),
                      value: _selectedForm,
                      items: MedicationFormConstants.medicationTypes
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedForm = value;
                          _selectedType = MedicationType.values.firstWhere(
                                (type) => type.toString().split('.').last == value!.toLowerCase().replaceAll(' ', ''),
                            orElse: () => MedicationType.tablet,
                          );
                          _unit = MedicationMatrix.getConcentrationUnits(_selectedType!).first;
                          _updateSummary();
                        });
                      },
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300,
                      style: Theme.of(context).textTheme.bodyLarge,
                      borderRadius: BorderRadius.circular(12),
                      validator: (value) => value == null ? MedicationFormConstants.typeRequiredMessage : null,
                    ),
                  ),
                  if (_selectedForm != null) ...[
                    const SizedBox(height: MedicationFormConstants.sectionSpacing),
                    if (_summary.isNotEmpty)
                      Text(
                        _summary,
                        style: MedicationFormConstants.summaryStyle(context),
                      ),
                    const SizedBox(height: MedicationFormConstants.sectionSpacing),
                    MedicationFormField(
                      controller: _nameController,
                      label: MedicationFormConstants.nameLabel,
                      helperText: MedicationFormConstants.nameHelper,
                      validator: (value) => value!.isEmpty ? MedicationFormConstants.nameRequiredMessage : null,
                    ),
                    const SizedBox(height: MedicationFormConstants.fieldSpacing),
                    MedicationFormField(
                      controller: _concentrationController,
                      label: MedicationFormConstants.concentrationLabel,
                      helperText: MedicationFormConstants.concentrationHelper,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value!.isEmpty
                          ? MedicationFormConstants.concentrationRequiredMessage
                          : double.tryParse(value) == null
                          ? MedicationFormConstants.invalidNumberMessage
                          : null,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              value: _unit,
                              items: MedicationMatrix.getConcentrationUnits(_selectedType!)
                                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _unit = value!;
                                  _updateSummary();
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () => _decrementField(_concentrationController),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _incrementField(_concentrationController),
                          ),
                        ],
                      ),
                      maxWidth: 200,
                    ),
                    const SizedBox(height: MedicationFormConstants.fieldSpacing),
                    MedicationFormField(
                      controller: _quantityController,
                      label: MedicationFormConstants.quantityLabel,
                      helperText: MedicationFormConstants.quantityHelper,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value!.isEmpty
                          ? MedicationFormConstants.quantityRequiredMessage
                          : double.tryParse(value) == null
                          ? MedicationFormConstants.invalidNumberMessage
                          : null,
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(MedicationFormConstants.unitsLabel,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () => _decrementField(_quantityController),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _incrementField(_quantityController),
                          ),
                        ],
                      ),
                      maxWidth: 200,
                    ),
                    const SizedBox(height: MedicationFormConstants.buttonSpacing),
                    ElevatedButton(
                      onPressed: _saveMedication,
                      style: MedicationFormConstants.buttonStyle,
                      child: const Text(MedicationFormConstants.saveButton),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}