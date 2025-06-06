// lib/features/dose/widgets/dose_form.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../../common/utils/calculations.dart';
import '../../../common/utils/formatters.dart'; // Add import
import '../../../common/medication_matrix.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/dose_form_constants.dart';
import 'dose_form_card.dart';
import 'dose_form_field.dart';

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
  late MedicationType _medicationType;

  @override
  void initState() {
    super.initState();
    _medicationType = _getMedicationType();
    _setUnitController();
    if (widget.selectedDose != null) {
      _updateFieldsForDose(widget.selectedDose!);
    } else {
      _nameController.text = widget.medication.name;
      _updateSummary();
    }
    _setupListeners();
  }

  @override
  void didUpdateWidget(covariant DoseForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDose != oldWidget.selectedDose && widget.selectedDose != null) {
      _updateFieldsForDose(widget.selectedDose!);
    } else if (widget.selectedDose == null) {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  MedicationType _getMedicationType() {
    return MedicationType.values.firstWhere(
          (type) => type.toString().split('.').last == widget.medication.form.toLowerCase().replaceAll(' ', ''),
      orElse: () => MedicationType.tablet,
    );
  }

  void _setupListeners() {
    _nameController.addListener(_onNameChanged);
    _tabletCountController.addListener(_onTabletCountChanged);
    _concentrationController.addListener(_onConcentrationChanged);
    _unitController.addListener(_updateSummary);
  }

  void _disposeControllers() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _tabletCountController.removeListener(_onTabletCountChanged);
    _tabletCountController.dispose();
    _concentrationController.removeListener(_onConcentrationChanged);
    _concentrationController.dispose();
    _unitController.removeListener(_updateSummary);
    _unitController.dispose();
  }

  void _setUnitController() {
    _unitController.text = _medicationType == MedicationType.tablet
        ? DoseFormConstants.defaultTabletUnit
        : MedicationMatrix.getAdministrationUnits(_medicationType).contains('mL')
        ? 'mL'
        : MedicationMatrix.getAdministrationUnits(_medicationType).first;
    _logger.info('Set unit controller to: ${_unitController.text}');
  }

  void _resetForm() {
    _nameController.text = widget.medication.name;
    _tabletCountController.clear();
    _concentrationController.clear();
    _setUnitController();
    _updateSummary();
  }

  void _updateFieldsForDose(Dose dose) {
    _nameController.text = dose.name ?? widget.medication.name;
    _nameEdited = dose.name != null && dose.name != widget.medication.name;
    if (_medicationType == MedicationType.tablet) {
      _tabletCountController.text = Utils.removeTrailingZeros(dose.amount);
      _concentrationController.text = Utils.removeTrailingZeros(dose.amount * widget.medication.concentration);
      _unitController.text = DoseFormConstants.defaultTabletUnit;
    } else {
      _concentrationController.text = Utils.removeTrailingZeros(dose.amount);
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
      _concentrationController.text = Utils.removeTrailingZeros(concentration);
    }
    _updateSummary();
  }

  void _onConcentrationChanged() {
    if (_concentrationController.text.isEmpty) return;
    final concentration = double.tryParse(_concentrationController.text) ?? 0;
    if (_medicationType == MedicationType.tablet) {
      final tabletCount = concentration / widget.medication.concentration;
      _tabletCountController.text = Utils.removeTrailingZeros(tabletCount);
    }
    _updateSummary();
  }

  void _updateSummary() {
    final name = _nameController.text.isEmpty ? DoseFormConstants.unnamedDose : _nameController.text;
    final amount = _medicationType == MedicationType.tablet
        ? (double.tryParse(_tabletCountController.text) ?? 0)
        : (double.tryParse(_concentrationController.text) ?? 0);
    final unit = _medicationType == MedicationType.tablet ? DoseFormConstants.tabletUnit : _unitController.text;
    String calculatedDose = '';
    if (amount > 0 && _medicationType == MedicationType.tablet) {
      final concentration = amount * widget.medication.concentration;
      calculatedDose = ' (${Utils.removeTrailingZeros(concentration)} ${_unitController.text})';
    }
    setState(() {
      _summary = amount > 0
          ? '$name - ${Utils.removeTrailingZeros(amount)} ${unit == DoseFormConstants.tabletUnit ? 'Tablet${amount == 1 ? '' : 's'}' : unit}$calculatedDose'
          : DoseFormConstants.noDoseSpecified;
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
    final unit = _medicationType == MedicationType.tablet ? DoseFormConstants.tabletUnit : _unitController.text;
    _logger.info('Saving dose: amount=$amount, unit=$unit');

    if (_medicationType == MedicationType.tablet && amount > widget.medication.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(DoseFormConstants.exceedStockMessage(widget.medication.stockQuantity))),
      );
      return;
    }

    if (!MedicationMatrix.isValidValue(
        _medicationType, amount, _medicationType == MedicationType.tablet ? 'quantity' : 'administration')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DoseFormConstants.invalidRangeMessage)),
      );
      return;
    }

    if (!(await _isDoseUnique(amount, unit))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DoseFormConstants.duplicateDoseMessage)),
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
        const SnackBar(content: Text(DoseFormConstants.doseSavedMessage)),
      );
      Navigator.pop(context);
    }).catchError((e) {
      _logger.severe('Error saving dose: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(DoseFormConstants.errorSavingDose(e))),
      );
    });
  }

  void _editDose(Dose dose) {
    widget.onEditDose(dose);
    _logger.info('Editing dose: id=${dose.id}, amount=${dose.amount}, unit=${dose.unit}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: DoseFormConstants.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _nameController.text.isEmpty ? DoseFormConstants.unnamedDose : _nameController.text,
                    style: DoseFormConstants.nameStyle(context),
                  ),
                  if (_summary.contains(' - '))
                    TextSpan(
                      text: _summary.substring(_summary.indexOf(' - ')),
                      style: DoseFormConstants.summaryStyle(context),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DoseFormConstants.sectionSpacing),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_medicationType == MedicationType.tablet) ...[
                    DoseFormCard(
                      title: '${DoseFormConstants.tabletCountLabel}: ${_tabletCountController.text.isEmpty ? DoseFormConstants.notSet : _tabletCountController.text}',
                      onTap: () => DoseFormField.showEditDialog(
                        context: context,
                        title: DoseFormConstants.editTabletCountTitle,
                        label: DoseFormConstants.tabletCountLabel,
                        controller: _tabletCountController,
                        helperText: DoseFormConstants.tabletCountHelper,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: DoseFormConstants.fieldSpacing),
                    DoseFormCard(
                      title: '${DoseFormConstants.concentrationLabel}: ${_concentrationController.text.isEmpty ? DoseFormConstants.notSet : _concentrationController.text} ${_unitController.text}',
                      onTap: () => DoseFormField.showEditDialog(
                        context: context,
                        title: DoseFormConstants.editConcentrationTitle,
                        label: DoseFormConstants.concentrationLabel,
                        controller: _concentrationController,
                        helperText: DoseFormConstants.concentrationHelperTablet,
                        keyboardType: TextInputType.number,
                        dropdownItems: MedicationMatrix.getAdministrationUnits(_medicationType).toSet().toList(),
                        dropdownValue: _unitController.text,
                        onDropdownChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _unitController.text = value;
                              _onConcentrationChanged();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: DoseFormConstants.fieldSpacing),
                  ] else ...[
                    DoseFormCard(
                      title: '${DoseFormConstants.concentrationLabel}: ${_concentrationController.text.isEmpty ? DoseFormConstants.notSet : _concentrationController.text} ${_unitController.text}',
                      onTap: () => DoseFormField.showEditDialog(
                        context: context,
                        title: DoseFormConstants.editConcentrationTitle,
                        label: DoseFormConstants.concentrationLabel,
                        controller: _concentrationController,
                        helperText: DoseFormConstants.concentrationHelperNonTablet,
                        keyboardType: TextInputType.number,
                        dropdownItems: MedicationMatrix.getAdministrationUnits(_medicationType).toSet().toList(),
                        dropdownValue: _unitController.text,
                        onDropdownChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _unitController.text = value;
                              _onConcentrationChanged();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: DoseFormConstants.fieldSpacing),
                  ],
                  DoseFormCard(
                    title: '${DoseFormConstants.doseNameLabel}: ${_nameController.text.isEmpty ? DoseFormConstants.notSet : _nameController.text}',
                    onTap: () => DoseFormField.showEditDialog(
                      context: context,
                      title: DoseFormConstants.editDoseNameTitle,
                      label: DoseFormConstants.doseNameLabel,
                      controller: _nameController,
                      helperText: DoseFormConstants.doseNameHelper,
                      validator: (value) => value!.isEmpty ? DoseFormConstants.doseNameRequired : null,
                      onChanged: _onNameChanged,
                    ),
                  ),
                  const SizedBox(height: DoseFormConstants.sectionSpacing),
                  ElevatedButton(
                    onPressed: _saveDose,
                    style: DoseFormConstants.buttonStyle,
                    child: Text(
                      widget.selectedDose == null ? DoseFormConstants.saveDoseButton : DoseFormConstants.updateDoseButton,
                      style: DoseFormConstants.buttonTextStyle(context),
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