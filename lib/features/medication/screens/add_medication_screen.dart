// lib/features/medication/screens/add_medication_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../widgets/medication_form_card.dart';
import '../widgets/medication_form_field.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
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
      _summary = '${Utils.removeTrailingZeros(quantity)} x '
          '${concentration > 0 ? Utils.removeTrailingZeros(concentration) : ''}$_unit '
          '$name $_selectedForm'
          '${total > 0 ? ' (${Utils.removeTrailingZeros(total)}$_unit total)' : ''}';
    });
  }

  Future<bool> _isNameUnique(String name) async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    return !medications.any((med) => med.name.toLowerCase() == name.toLowerCase());
  }

  void _incrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    controller.text = Utils.removeTrailingZeros(currentValue + 1);
  }

  void _decrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = Utils.removeTrailingZeros(currentValue - 1);
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(MedicationFormConstants.addMedicationTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form( // Removed Padding widget
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: MedicationFormCard(
                    child: DropdownButtonFormField<String>(
                      decoration: MedicationFormConstants.dropdownDecoration.copyWith(
                        labelText: null,
                        hint: const Text('Select Medication Type'),
                        helperText: 'Choose Medication Type',
                        helperMaxLines: 2,
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
                ),
                if (_selectedForm != null) ...[
                  const SizedBox(height: MedicationFormConstants.sectionSpacing),
                  if (_summary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Minimal padding for summary
                      child: Text(
                        _summary,
                        style: MedicationFormConstants.summaryStyle(context),
                      ),
                    ),
                  const SizedBox(height: MedicationFormConstants.sectionSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: MedicationFormCard(
                      child: MedicationFormField(
                        controller: _nameController,
                        label: MedicationFormConstants.nameLabel,
                        helperText: 'Enter the name of the Medication',
                        helperMaxLines: 2,
                        validator: (value) => value!.isEmpty ? MedicationFormConstants.nameRequiredMessage : null,
                        maxWidth: screenWidth * 0.65, // 65% field width
                      ),
                    ),
                  ),
                  const SizedBox(height: MedicationFormConstants.fieldSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: MedicationFormCard(
                      child: MedicationFormField(
                        controller: _concentrationController,
                        label: MedicationFormConstants.concentrationLabel,
                        helperText: 'Enter the Concentration',
                        helperMaxLines: 2,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) => value != null && value.isEmpty
                            ? MedicationFormConstants.concentrationRequiredMessage
                            : value != null && double.tryParse(value) == null
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
                        maxWidth: screenWidth * 0.65, // 65% field width
                      ),
                    ),
                  ),
                  const SizedBox(height: MedicationFormConstants.fieldSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: MedicationFormCard(
                      child: MedicationFormField(
                        controller: _quantityController,
                        label: MedicationFormConstants.quantityLabel,
                        helperText: 'Enter the Amount of $_selectedForm',
                        helperMaxLines: 2,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) => value != null && value.isEmpty
                            ? MedicationFormConstants.quantityRequiredMessage
                            : value != null && double.tryParse(value) == null
                            ? MedicationFormConstants.invalidNumberMessage
                            : null,
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                MedicationFormConstants.unitsLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
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
                        maxWidth: screenWidth * 0.65, // 65% field width
                      ),
                    ),
                  ),
                  const SizedBox(height: MedicationFormConstants.buttonSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMedication,
                      style: MedicationFormConstants.buttonStyle,
                      child: const Text(MedicationFormConstants.saveButton),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}