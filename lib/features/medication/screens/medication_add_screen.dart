import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../common/widgets/summary_card.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../utils/medication_form_utils.dart';
import '../widgets/medication_add_form.dart';

class MedicationsAddScreen extends ConsumerStatefulWidget {
  const MedicationsAddScreen({super.key});

  @override
  ConsumerState<MedicationsAddScreen> createState() => _MedicationsAddScreenState();
}

class _MedicationsAddScreenState extends ConsumerState<MedicationsAddScreen> {
  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _controllers = MedicationFormUtils.createControllers();
  final MedicationFormUtils _utils = MedicationFormUtils();
  String _unit = MedicationFormConstants.defaultUnit;
  String? _selectedForm;
  String? _selectedSubType;
  MedicationType _selectedType = MedicationType.tablet;
  bool _requiresReconstitution = false;
  List<String> _existingMedicationNames = [];
  String _summary = '';
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _selectedForm = MedicationFormConstants.forms.first;
    _selectedSubType = MedicationFormConstants.subTypes[_selectedType]?.first;
    _unit = MedicationMatrix.getConcentrationUnits(_selectedType).first;
    _controllers['quantity']!.text = '1';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingMedications();
    });
    _utils.setupListeners(
      _controllers,
      () => setState(
        () => _summary = _utils.buildSummary(
          name: _controllers['name']!.text,
          selectedType: _selectedType,
          selectedForm: _selectedForm,
          selectedSubType: _selectedSubType,
          concentration: _controllers['concentration']!.text,
          quantity: _controllers['quantity']!.text,
          volume: _controllers['volume']!.text,
          unit: _unit,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _utils.disposeControllers(_controllers);
    super.dispose();
  }

  Future<void> _loadExistingMedications() async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    setState(() {
      _existingMedicationNames = medications.map((med) => med.name).toList();
    });
  }

  Future<void> _saveMedication() async {
    if (!_formKeys[_currentStep].currentState!.validate()) return;

    final validationResult = await _utils.validateInput(
      context: context,
      controllers: _controllers,
      selectedType: _selectedType,
      selectedSubType: _selectedSubType,
      requiresReconstitution: _requiresReconstitution,
      isNameUnique: (name) async {
        final medications = await ref.read(driftServiceProvider).getMedications();
        return !medications.any((med) => med.name.toLowerCase() == name.toLowerCase());
      },
    );

    if (!validationResult['valid']) return;

    try {
      final medication = MedicationsCompanion(
        name: drift.Value(_controllers['name']!.text),
        concentration: drift.Value(double.parse(_controllers['concentration']!.text)),
        concentrationUnit: drift.Value(_unit),
        stockQuantity: drift.Value(
          _utils.getStockQuantity(
            selectedType: _selectedType,
            quantity: _controllers['quantity']!.text,
            volume: _controllers['volume']!.text,
          ),
        ),
        form: drift.Value(_selectedForm!),
      );

      await ref.read(driftServiceProvider).addMedication(medication);
      ref.invalidate(medicationsProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(MedicationFormConstants.medicationSavedMessage)));
    } catch (e, stack) {
      debugPrint('Save error: $e\n$stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(MedicationFormConstants.errorSavingMessage(e))));
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0 && _selectedForm == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(MedicationFormConstants.selectTypeMessage)));
      return;
    }
    if (_currentStep == 1 && _controllers['name']!.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(MedicationFormConstants.nameRequiredMessage)));
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      final formula = _utils.buildSummary(
        name: _controllers['name']!.text,
        selectedType: _selectedType,
        selectedForm: _selectedForm,
        selectedSubType: _selectedSubType,
        concentration: _controllers['concentration']!.text,
        quantity: _controllers['quantity']!.text,
        volume: _controllers['volume']!.text,
        unit: _unit,
      );
      final formulaParts = formula.split('|');
      if (formulaParts.length < 7) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid medication summary')));
        return;
      }
      showDialog(
        context: context,
        builder: (context) => StandardDialog(
          title: 'Save the following medication?', // Updated title
          contentWidget: SummaryCard(
            medName: formulaParts[0],
            medType: formulaParts[1],
            strengthValue: formulaParts[2],
            medQtyUnit: formulaParts[3],
            medQty: formulaParts[4],
            totalStrength: formulaParts[5],
            unit: formulaParts[6],
            maxWidth: MediaQuery.of(context).size.width * 0.85,
            noBackground: true,
          ),
          onConfirm: () {
            Navigator.pop(context);
            _saveMedication();
          },
          confirmText: 'Confirm', // Updated button text
        ),
      );
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MedicationFormConstants.addMedicationTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          return Padding(
            padding: MedicationFormConstants.controlsPadding, // Increased vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: Text(_currentStep == 2 ? 'Save' : 'Continue'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(
                    _currentStep == 0 ? 'Cancel' : 'Back',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Select Type'),
            content: MedicationAddForm(
              formKey: _formKeys[0],
              controllers: _controllers,
              selectedType: _selectedType,
              selectedForm: _selectedForm,
              selectedSubType: _selectedSubType,
              unit: _unit,
              requiresReconstitution: _requiresReconstitution,
              currentStep: 0,
              existingMedicationNames: _existingMedicationNames,
              summary: _summary,
              onTypeChanged: (type, form, subType) {
                setState(() {
                  _selectedType = type;
                  _selectedForm = form;
                  _selectedSubType = subType;
                  _unit = MedicationMatrix.getConcentrationUnits(type).first;
                  _requiresReconstitution = subType == 'Reconstituted Vial';
                  _summary = _utils.buildSummary(
                    name: _controllers['name']!.text,
                    selectedType: _selectedType,
                    selectedForm: _selectedForm,
                    selectedSubType: _selectedSubType,
                    concentration: _controllers['concentration']!.text,
                    quantity: _controllers['quantity']!.text,
                    volume: _controllers['volume']!.text,
                    unit: _unit,
                  );
                });
              },
              onUnitChanged: (value) => setState(() => _unit = value!),
              onReconstitutionChanged: (value) => setState(() => _requiresReconstitution = value),
              onSubTypeChanged: (value) => setState(() {
                _selectedSubType = value;
                _requiresReconstitution = value == 'Reconstituted Vial';
              }),
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Enter Name'),
            content: MedicationAddForm(
              formKey: _formKeys[1],
              controllers: _controllers,
              selectedType: _selectedType,
              selectedForm: _selectedForm,
              selectedSubType: _selectedSubType,
              unit: _unit,
              requiresReconstitution: _requiresReconstitution,
              currentStep: 1,
              existingMedicationNames: _existingMedicationNames,
              summary: _summary,
              onTypeChanged: null,
              onUnitChanged: null,
              onReconstitutionChanged: null,
              onSubTypeChanged: null,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Enter Details'),
            content: MedicationAddForm(
              formKey: _formKeys[2],
              controllers: _controllers,
              selectedType: _selectedType,
              selectedForm: _selectedForm,
              selectedSubType: _selectedSubType,
              unit: _unit,
              requiresReconstitution: _requiresReconstitution,
              currentStep: 2,
              existingMedicationNames: _existingMedicationNames,
              summary: _summary,
              onTypeChanged: null,
              onUnitChanged: (value) => setState(() => _unit = value!),
              onReconstitutionChanged: (value) => setState(() => _requiresReconstitution = value),
              onSubTypeChanged: (value) => setState(() {
                _selectedSubType = value;
                _requiresReconstitution = value == 'Reconstituted Vial';
              }),
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
            ),
            isActive: _currentStep == 2,
          ),
        ],
      ),
    );
  }
}