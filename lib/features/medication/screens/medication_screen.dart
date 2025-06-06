import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../widgets/medication_form_card.dart';
import '../widgets/medication_form_field.dart';

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
  final _unitController = TextEditingController(text: MedicationFormConstants.defaultUnit);
  final _quantityController = TextEditingController();
  String? _selectedForm;
  MedicationType? _selectedType;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _initializeFields(widget.medication!);
    }
    _setupListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeFields(Medication med) {
    _nameController.text = med.name;
    _concentrationController.text = med.concentration.toString();
    _unitController.text = med.concentrationUnit.isEmpty ? MedicationFormConstants.defaultUnit : med.concentrationUnit;
    _quantityController.text = med.stockQuantity.toString();
    _selectedForm = med.form;
    _selectedType = MedicationType.values.firstWhere(
          (type) => type.toString().split('.').last == med.form.toLowerCase().replaceAll(' ', ''),
      orElse: () => MedicationType.tablet,
    );
    _updateSummary();
  }

  void _setupListeners() {
    _nameController.addListener(_updateSummary);
    _concentrationController.addListener(_updateSummary);
    _unitController.addListener(_updateSummary);
    _quantityController.addListener(_updateSummary);
  }

  void _disposeControllers() {
    _nameController.removeListener(_updateSummary);
    _nameController.dispose();
    _concentrationController.removeListener(_updateSummary);
    _concentrationController.dispose();
    _unitController.removeListener(_updateSummary);
    _unitController.dispose();
    _quantityController.removeListener(_updateSummary);
    _quantityController.dispose();
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
    final form = _selectedForm ?? MedicationFormConstants.defaultForm;
    final total = concentration * quantity;
    setState(() {
      _summary = '$quantity x ${concentration > 0 ? concentration : ''}$unit $name $form${total > 0 ? ' (${total}$unit total)' : ''}';
    });
  }

  Future<bool> _hasDosesOrSchedules() async {
    if (widget.medication == null) return false;
    final doses = await ref.read(driftServiceProvider).getDoses(widget.medication!.id);
    if (doses.isNotEmpty) return true;
    final schedules = await ref.read(driftServiceProvider).getSchedules(widget.medication!.id);
    return schedules.isNotEmpty;
  }

  Future<bool> _isNameUnique(String name) async {
    final medications = await ref.read(driftServiceProvider).getMedications();
    return !medications.any((med) =>
    med.name.toLowerCase() == name.toLowerCase() && (widget.medication == null || med.id != widget.medication!.id));
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
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed in MedicationScreen');
      return;
    }

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
          title: const Text(MedicationFormConstants.warningTitle),
          content: const Text(MedicationFormConstants.warningContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(MedicationFormConstants.cancelButton),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performSave(medication);
              },
              child: const Text(MedicationFormConstants.proceedButton),
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
        const SnackBar(content: Text(MedicationFormConstants.medicationSavedMessage)),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(MedicationFormConstants.errorSavingMessage(e))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication?.name ?? MedicationFormConstants.addMedicationTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: MedicationFormConstants.formPadding,
          child: _selectedForm == null && widget.medication == null
              ? _buildTypeSelection(context)
              : _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildTypeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          MedicationFormConstants.selectTypeTitle,
          style: MedicationFormConstants.titleStyle,
        ),
        const SizedBox(height: MedicationFormConstants.sectionSpacing),
        MedicationFormCard(
          child: DropdownButtonFormField<String>(
            decoration: MedicationFormConstants.dropdownDecoration,
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
                _unitController.text = MedicationFormConstants.defaultUnit;
                _updateSummary();
              });
            },
            validator: (value) => value == null ? MedicationFormConstants.typeRequiredMessage : null,
          ),
        ),
        const SizedBox(height: MedicationFormConstants.sectionSpacing),
        ElevatedButton(
          onPressed: () {
            if (_selectedForm != null) {
              setState(() {});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(MedicationFormConstants.selectTypeMessage)),
              );
            }
          },
          style: MedicationFormConstants.buttonStyle,
          child: const Text(MedicationFormConstants.continueButton),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_summary.isNotEmpty)
          Text(
            _summary,
            style: MedicationFormConstants.summaryStyle(context),
          ),
        const SizedBox(height: MedicationFormConstants.sectionSpacing),
        Form(
          key: _formKey,
          child: Column(
            children: [
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
                    Text(_unitController.text, style: Theme.of(context).textTheme.bodyLarge),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _decrementField(_concentrationController),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _incrementField(_concentrationController),
                    ),
                  ],
                ),
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
                    Text(MedicationFormConstants.unitsLabel, style: Theme.of(context).textTheme.bodyLarge),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _decrementField(_quantityController),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _incrementField(_quantityController),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MedicationFormConstants.fieldSpacing),
              MedicationFormCard(
                child: DropdownButtonFormField<String>(
                  decoration: MedicationFormConstants.dropdownDecoration,
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
                      _unitController.text = MedicationFormConstants.defaultUnit;
                      _updateSummary();
                    });
                  },
                  validator: (value) => value == null ? MedicationFormConstants.typeRequiredMessage : null,
                ),
              ),
              const SizedBox(height: MedicationFormConstants.buttonSpacing),
              ElevatedButton(
                onPressed: _saveMedication,
                style: MedicationFormConstants.buttonStyle,
                child: const Text(MedicationFormConstants.saveButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}