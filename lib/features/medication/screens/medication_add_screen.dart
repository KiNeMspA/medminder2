import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/constants/app_strings.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../widgets/type_specific_fields/tablet_fields.dart';
import '../widgets/type_specific_fields/injection_fields.dart';
import '../widgets/type_specific_fields/drops_fields.dart';

class MedicationsAddScreen extends ConsumerStatefulWidget {
  const MedicationsAddScreen({super.key});

  @override
  ConsumerState<MedicationsAddScreen> createState() => _MedicationsAddScreenState();
}

class _MedicationsAddScreenState extends ConsumerState<MedicationsAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _concentrationController = TextEditingController(text: '0');
  final _quantityController = TextEditingController(text: '0');
  final _volumeController = TextEditingController(text: '0');
  final _totalLiquidController = TextEditingController(text: '0');
  final _powderAmountController = TextEditingController(text: '0');
  final _solventVolumeController = TextEditingController(text: '0');
  String _unit = MedicationFormConstants.defaultUnit;
  MedicationType _selectedType = MedicationType.tablet;
  String? _selectedForm;
  String _summary = '';
  bool _requiresReconstitution = false;
  String _deliveryMethod = 'Pre-filled Syringe';
  int _currentStep = 0;
  List<String> _existingMedicationNames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingMedications();
    _selectedForm = Units.forms.first;
    _unit = MedicationMatrix.getConcentrationUnits(_selectedType).first;
    _updateSummary();
    _setupListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _concentrationController.dispose();
    _quantityController.dispose();
    _volumeController.dispose();
    _totalLiquidController.dispose();
    _powderAmountController.dispose();
    _solventVolumeController.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _nameController.addListener(_updateSummary);
    _concentrationController.addListener(_updateSummary);
    _quantityController.addListener(_updateSummary);
    _volumeController.addListener(_updateSummary);
    _totalLiquidController.addListener(_updateSummary);
    _powderAmountController.addListener(_updateSummary);
    _solventVolumeController.addListener(_updateSummary);
  }

  Future<void> _loadExistingMedications() async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    setState(() {
      _existingMedicationNames = medications.map((med) => med.name).toList();
    });
  }

  void _updateSummary() {
    if (_nameController.text.isEmpty || _selectedForm == null) {
      _summary = '';
      return;
    }
    final name = _nameController.text;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final volume = double.tryParse(_volumeController.text) ?? 0;
    final totalLiquid = double.tryParse(_totalLiquidController.text) ?? 0;
    String summary = '';
    if (_selectedType == MedicationType.tablet || _selectedType == MedicationType.capsule) {
      final total = concentration * quantity;
      final pluralForm = quantity == 1 ? _selectedForm! : '${_selectedForm}s';
      summary = '${Utils.removeTrailingZeros(quantity)} x ${Utils.removeTrailingZeros(concentration)}$_unit $pluralForm${total > 0 ? ' (${Utils.removeTrailingZeros(total)}$_unit total)' : ''}';
    } else if (_selectedType == MedicationType.injection) {
      summary = '${Utils.removeTrailingZeros(concentration)}$_unit $name ${_selectedForm}${_requiresReconstitution ? ' (Reconstituted)' : ''} (${totalLiquid > 0 ? Utils.removeTrailingZeros(totalLiquid) : 'N/A'} mL)';
    } else if (_selectedType == MedicationType.drops) {
      summary = '${Utils.removeTrailingZeros(volume)} mL $name ${_selectedForm}';
    } else if (_selectedType == MedicationType.inhaler || _selectedType == MedicationType.nasalSpray) {
      summary = '${Utils.removeTrailingZeros(quantity)} ${_selectedForm} $name (${Utils.removeTrailingZeros(concentration)}$_unit)';
    } else if (_selectedType == MedicationType.ointmentCream) {
      summary = '${Utils.removeTrailingZeros(quantity)} g $name ${_selectedForm} (${Utils.removeTrailingZeros(concentration)}$_unit)';
    } else if (_selectedType == MedicationType.patch || _selectedType == MedicationType.suppository) {
      summary = '${Utils.removeTrailingZeros(quantity)} ${_selectedForm} $name (${Utils.removeTrailingZeros(concentration)}$_unit)';
    }
    setState(() => _summary = summary);
  }

  Future<bool> _isNameUnique(String name) async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    return !medications.any((med) => med.name.toLowerCase() == name.toLowerCase());
  }

  void _incrementField(TextEditingController controller, {bool isInteger = false}) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    final newValue = isInteger ? currentValue + 1 : currentValue + 0.01;
    controller.text = isInteger ? newValue.toInt().toString() : Utils.removeTrailingZeros(newValue);
  }

  void _decrementField(TextEditingController controller, {bool isInteger = false}) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      final newValue = isInteger ? currentValue - 1 : currentValue - 0.01;
      controller.text = isInteger ? newValue.toInt().toString() : Utils.removeTrailingZeros(newValue);
    }
  }

  void _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final volume = double.tryParse(_volumeController.text) ?? 0;
    final totalLiquid = double.tryParse(_totalLiquidController.text) ?? 0;
    final powderAmount = double.tryParse(_powderAmountController.text) ?? 0;

    try {
      if (_selectedType == MedicationType.injection) {
        if (_requiresReconstitution && powderAmount <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Powder amount required for reconstituted vials')),
          );
          return;
        }
        if (!_requiresReconstitution && _deliveryMethod == 'Vial' && totalLiquid <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Total volume required for non-reconstituted vials')),
          );
          return;
        }
      }

      if (_selectedType == MedicationType.drops && volume <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total volume required for drops')),
        );
        return;
      }

      if (concentration <= 0 || (_selectedType == MedicationType.drops && volume <= 0) ||
          (_selectedType != MedicationType.injection && quantity <= 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All values must be greater than 0')),
        );
        return;
      }

      if (!MedicationMatrix.isValidValue(_selectedType, concentration, 'concentration')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Concentration out of valid range (0.0001–999)')),
        );
        return;
      }

      if (_selectedType != MedicationType.injection && !MedicationMatrix.isValidValue(_selectedType, quantity, 'quantity') ||
          (_selectedType == MedicationType.drops && !MedicationMatrix.isValidValue(_selectedType, volume, 'quantity')) ||
          (_selectedType == MedicationType.injection && !_requiresReconstitution && _deliveryMethod == 'Vial' && !MedicationMatrix.isValidValue(_selectedType, totalLiquid, 'quantity'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity or volume out of valid range (0.01–999)')),
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
        stockQuantity: drift.Value(_selectedType == MedicationType.drops ? volume : _selectedType == MedicationType.injection ? totalLiquid : quantity),
        form: drift.Value(_selectedForm!),
      );

      await ref.read(driftServiceProvider).addMedication(medication);
      ref.invalidate(medicationsProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MedicationFormConstants.medicationSavedMessage)),
      );
    } catch (e, stack) {
      debugPrint('Save error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MedicationFormConstants.errorSavingMessage(e))),
      );
    }
  }

  String get _quantityUnit {
    if (_selectedType == MedicationType.tablet) return (double.tryParse(_quantityController.text) ?? 0) == 1 ? 'Tablet' : 'Tablets';
    if (_selectedType == MedicationType.capsule) return (double.tryParse(_quantityController.text) ?? 0) == 1 ? 'Capsule' : 'Capsules';
    if (_selectedType == MedicationType.patch) return (double.tryParse(_quantityController.text) ?? 0) == 1 ? 'Patch' : 'Patches';
    if (_selectedType == MedicationType.suppository) return (double.tryParse(_quantityController.text) ?? 0) == 1 ? 'Suppository' : 'Suppositories';
    return '';
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Select Medication Type'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Units.forms.map((form) {
                final type = MedicationType.values.firstWhere(
                      (t) => t.toString().split('.').last == form.toLowerCase().replaceAll('/', '').replaceAll(' ', ''),
                  orElse: () => MedicationType.tablet,
                );
                return ChoiceChip(
                  label: Text(form),
                  avatar: Icon(_getIconForForm(form)),
                  selected: _selectedForm == form,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedForm = form;
                        _selectedType = type;
                        _unit = MedicationMatrix.getConcentrationUnits(_selectedType).first;
                        _requiresReconstitution = false;
                        _deliveryMethod = 'Pre-filled Syringe';
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
        title: const Text('Medication Name'),
        content: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _existingMedicationNames.where((String option) =>
                option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            _nameController.text = selection;
            _updateSummary();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: _nameController,
              focusNode: focusNode,
              decoration: MedicationFormConstants.textFieldDecoration('Medication Name'),
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
              onChanged: (value) => _updateSummary(),
            );
          },
        ),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Concentration & Unit'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _concentrationController,
                    decoration: MedicationFormConstants.textFieldDecoration('Concentration'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null ? 'Valid number required' : null,
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => _incrementField(_concentrationController),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _decrementField(_concentrationController),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: MedicationMatrix.getConcentrationUnits(_selectedType).map((unitType) {
                return ChoiceChip(
                  label: Text(unitType),
                  selected: _unit == unitType,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _unit = unitType;
                        _updateSummary();
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        isActive: _currentStep == 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Quantity/Volume'),
        content: _selectedType == MedicationType.tablet || _selectedType == MedicationType.capsule ||
            _selectedType == MedicationType.patch || _selectedType == MedicationType.suppository
            ? TabletFields(
          concentrationController: _concentrationController,
          quantityController: _quantityController,
          unitController: TextEditingController(text: _unit),
          selectedType: _selectedType,
          onUnitChanged: (value) => setState(() => _unit = value ?? _unit),
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        )
            : _selectedType == MedicationType.injection
            ? InjectionFields(
          concentrationController: _concentrationController,
          unitController: TextEditingController(text: _unit),
          powderAmountController: _powderAmountController,
          solventVolumeController: _solventVolumeController,
          totalLiquidController: _totalLiquidController,
          requiresReconstitution: _requiresReconstitution,
          onReconstitutionChanged: (value) => setState(() => _requiresReconstitution = value),
          onUnitChanged: (value) => setState(() => _unit = value ?? _unit),
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        )
            : _selectedType == MedicationType.drops
            ? DropsFields(
          concentrationController: _concentrationController,
          volumeController: _volumeController,
          unitController: TextEditingController(text: _unit),
          onUnitChanged: (value) => setState(() => _unit = value ?? _unit),
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: MedicationFormConstants.textFieldDecoration('Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null ? 'Valid number required' : null,
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () => _incrementField(_quantityController, isInteger: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _decrementField(_quantityController, isInteger: true),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep == 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  IconData _getIconForForm(String form) {
    switch (form) {
      case 'Tablet':
        return Icons.tablet;
      case 'Capsule':
        return Icons.medication;
      case 'Injection':
        return Icons.medical_services;
      case 'Drops':
        return Icons.water_drop;
      case 'Inhaler':
        return Icons.air;
      case 'Ointment/Cream':
        return Icons.spa;
      case 'Patch':
        return Icons.healing;
      case 'Nasal Spray':
        return Icons.sanitizer;
      case 'Suppository':
        return Icons.medical_information;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MedicationFormConstants.addMedicationTitle),
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
                      if (_currentStep == 0 && _selectedForm == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a medication type')),
                        );
                        return;
                      }
                      if (_currentStep == 1 && _nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a medication name')),
                        );
                        return;
                      }
                      if (_currentStep < _buildSteps().length - 1) {
                        setState(() => _currentStep += 1);
                      } else {
                        _saveMedication();
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