// lib/screens/dose/dose_form.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../core/calculations.dart';
import '../../core/medication_matrix.dart';
import '../../core/utils.dart';
import '../../data/database.dart';
import '../../services/drift_service.dart';
import '../../widgets/form_widgets.dart';

class DoseForm extends ConsumerStatefulWidget {
  final Medication medication;
  final Function(Dose) onEditDose;
  final Function onClearForm;
  final Dose? selectedDose;

  const DoseForm({
    super.key,
    required this.medication,
    required this.onEditDose,
    required this.onClearForm,
    this.selectedDose,
  });

  @override
  ConsumerState<DoseForm> createState() => _DoseFormState();
}

class _DoseFormState extends ConsumerState<DoseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tabletCountController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _unitController = TextEditingController();
  bool _nameEdited = false;
  String _summary = '';
  final Logger _logger = Logger('DoseForm');
  MedicationType _medicationType = MedicationType.tablet;

  @override
  void initState() {
    super.initState();
    _medicationType = MedicationType.values.firstWhere(
          (type) => type.toString().split('.').last == widget.medication.form.toLowerCase().replaceAll(' ', ''),
      orElse: () => MedicationType.tablet,
    );
    _setUnitController();
    if (widget.selectedDose != null) {
      _updateFieldsForDose(widget.selectedDose!);
    } else {
      _nameController.text = widget.medication.name;
      _updateSummary();
    }
    _nameController.addListener(_onNameChanged);
    _tabletCountController.addListener(_onTabletCountChanged);
    _concentrationController.addListener(_onConcentrationChanged);
    _unitController.addListener(_updateSummary);
  }

  @override
  void didUpdateWidget(covariant DoseForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDose != oldWidget.selectedDose && widget.selectedDose != null) {
      _updateFieldsForDose(widget.selectedDose!);
    } else if (widget.selectedDose == null) {
      _nameController.text = widget.medication.name;
      _tabletCountController.clear();
      _concentrationController.clear();
      _setUnitController();
      _updateSummary();
    }
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameChanged)
      ..dispose();
    _tabletCountController
      ..removeListener(_onTabletCountChanged)
      ..dispose();
    _concentrationController
      ..removeListener(_onConcentrationChanged)
      ..dispose();
    _unitController
      ..removeListener(_updateSummary)
      ..dispose();
    super.dispose();
  }

  void _setUnitController() {
    if (_medicationType == MedicationType.tablet) {
      _unitController.text = 'mg';
    } else {
      final units = MedicationMatrix.getAdministrationUnits(_medicationType);
      _unitController.text = units.contains('mL') ? 'mL' : units.first;
    }
    _logger.info('Set unit controller to: ${_unitController.text}');
  }

  void _updateFieldsForDose(Dose dose) {
    _nameController.text = dose.name ?? widget.medication.name;
    _nameEdited = dose.name != null && dose.name != widget.medication.name;
    if (_medicationType == MedicationType.tablet) {
      _tabletCountController.text = MedCalculations.formatNumber(dose.amount);
      _concentrationController.text = MedCalculations.formatNumber(dose.amount * widget.medication.concentration);
      _unitController.text = 'mg';
    } else {
      _concentrationController.text = MedCalculations.formatNumber(dose.amount);
      _unitController.text = dose.unit;
    }
    _updateSummary();
  }

  void _onNameChanged() {
    _nameEdited = _nameController.text.isNotEmpty && _nameController.text != widget.medication.name;
    _updateSummary();
  }

  void _onTabletCountChanged() {
    if (_tabletCountController.text.isEmpty) return;
    final tabletCount = double.tryParse(_tabletCountController.text) ?? 0;
    if (_medicationType == MedicationType.tablet) {
      final concentration = tabletCount * widget.medication.concentration;
      _concentrationController.text = MedCalculations.formatNumber(concentration);
    }
    _updateSummary();
  }

  void _onConcentrationChanged() {
    if (_concentrationController.text.isEmpty) return;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    if (_medicationType == MedicationType.tablet) {
      final tabletCount = concentration / widget.medication.concentration;
      _tabletCountController.text = MedCalculations.formatNumber(tabletCount);
    }
    _updateSummary();
  }

  void _updateSummary() {
    final name = _nameController.text.isEmpty ? 'Unnamed Dose' : _nameController.text;
    final amount = _medicationType == MedicationType.tablet
        ? (double.tryParse(_tabletCountController.text) ?? 0)
        : (double.tryParse(_concentrationController.text) ?? 0);
    final unit = _medicationType == MedicationType.tablet ? 'Tablet' : _unitController.text;
    String calculatedDose = '';
    if (amount > 0 && _medicationType == MedicationType.tablet) {
      final concentration = amount * widget.medication.concentration;
      calculatedDose = ' (${concentration.toStringAsFixed(2)} ${_unitController.text})';
    }
    setState(() {
      _summary = amount > 0 ? '$name - $amount ${unit == 'Tablet' ? 'Tablet${amount == 1 ? '' : 's'}' : unit}$calculatedDose' : 'No dose specified';
    });
  }

  Future<bool> _isDoseUnique(double amount, String unit) async {
    final doses = await ref.read(driftServiceProvider).getDoses(widget.medication.id);
    return !doses.any((dose) =>
    dose.amount == amount &&
        dose.unit == unit &&
        (widget.selectedDose == null || dose.id != widget.selectedDose!.id));
  }

  void _saveDose() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _medicationType == MedicationType.tablet
        ? (double.tryParse(_tabletCountController.text) ?? 0)
        : (double.tryParse(_concentrationController.text) ?? 0);
    final unit = _medicationType == MedicationType.tablet ? 'Tablet' : _unitController.text;
    _logger.info('Saving dose: amount=$amount, unit=$unit');

    if (_medicationType == MedicationType.tablet && amount > widget.medication.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dose exceeds available stock (${widget.medication.stockQuantity} tablets)')),
      );
      return;
    }

    if (!MedicationMatrix.isValidValue(_medicationType, amount, _medicationType == MedicationType.tablet ? 'quantity' : 'administration')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose value out of valid range (0.01–999)')),
      );
      return;
    }

    if (!(await _isDoseUnique(amount, unit))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A dose with this amount and unit already exists')),
      );
      return;
    }

    final dose = DosesCompanion(
      medicationId: drift.Value(widget.medication.id),
      amount: drift.Value(amount),
      unit: drift.Value(unit),
      name: drift.Value(_nameController.text),
    );

    ref.read(driftServiceProvider).addDose(dose).then((doseId) {
      _logger.info('Dose saved: id=$doseId');
      ref.invalidate(dosesProvider(widget.medication.id));
      widget.onClearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose saved')),
      );
      Navigator.pop(context);
    }).catchError((e) {
      _logger.severe('Error saving dose: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving dose: $e')),
      );
    });
  }

  void _editDose(Dose dose) {
    widget.onEditDose(dose);
    _logger.info('Editing dose: id=${dose.id}, amount=${dose.amount}, unit=${dose.unit}');
  }

  Future<void> _editField({
    required String title,
    required String label,
    required TextEditingController controller,
    String? helperText,
    TextInputType? keyboardType,
    List<String>? dropdownItems,
  }) async {
    final result = await FormWidgets.showInputDialog(
      context: context,
      title: title,
      initialValue: controller.text,
      label: label,
      helperText: helperText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? '$label is required' : double.tryParse(value) == null ? 'Enter a valid number' : null,
      dropdownItems: dropdownItems,
      dropdownValue: _unitController.text.isNotEmpty ? _unitController.text : null,
      onDropdownChanged: (value) {
        if (value != null) {
          setState(() {
            _unitController.text = value;
            _onConcentrationChanged();
          });
        }
      },
    );
    if (result != null) {
      setState(() {
        controller.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _nameController.text.isEmpty ? 'Unnamed Dose' : _nameController.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (_summary.contains(' - '))
                    TextSpan(
                      text: _summary.substring(_summary.indexOf(' - ')),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_medicationType == MedicationType.tablet) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          'Number of Tablets: ${_tabletCountController.text.isEmpty ? 'Not set' : _tabletCountController.text}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () => _editField(
                          title: 'Edit Tablet Count',
                          label: 'Number of Tablets',
                          controller: _tabletCountController,
                          helperText: 'Enter the number of tablets (e.g., 2)',
                          keyboardType: TextInputType.number,
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
                        onTap: () => _editField(
                          title: 'Edit Concentration',
                          label: 'Concentration',
                          controller: _concentrationController,
                          helperText: 'Enter the total active compound (e.g., 200 mg)',
                          keyboardType: TextInputType.number,
                          dropdownItems: MedicationMatrix.getAdministrationUnits(_medicationType).toSet().toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
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
                        onTap: () => _editField(
                          title: 'Edit Concentration',
                          label: 'Concentration',
                          controller: _concentrationController,
                          helperText: 'Enter the dose amount (e.g., 1 mL)',
                          keyboardType: TextInputType.number,
                          dropdownItems: MedicationMatrix.getAdministrationUnits(_medicationType).toSet().toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        'Dose Name: ${_nameController.text.isEmpty ? 'Not set' : _nameController.text}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () async {
                        final result = await FormWidgets.showInputDialog(
                          context: context,
                          title: 'Edit Dose Name',
                          initialValue: _nameController.text,
                          label: 'Dose Name',
                          helperText: 'Enter a name for the dose (e.g., Ibuprofen Tablet)',
                          validator: (value) => value!.isEmpty ? 'Name is required' : null,
                        );
                        if (result != null) {
                          setState(() {
                            _nameController.text = result;
                            _onNameChanged();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveDose,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.selectedDose == null ? 'Save Dose' : 'Update Dose',
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