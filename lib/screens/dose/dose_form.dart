// lib/screens/dose/dose_form.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:logging/logging.dart';
import '../../core/calculations.dart';
import '../../core/constants.dart';
import '../../core/controller_mixin.dart';
import '../../core/medication_matrix.dart';
import '../../core/utils.dart';
import '../../data/database.dart';
import '../../services/drift_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/form_widgets.dart';

class DoseForm extends ConsumerStatefulWidget {
  final Medication medication;
  final Function(Dose) onEditDose;
  final Function onClearForm;
  final Function onDismissKeyboard;

  const DoseForm({
    super.key,
    required this.medication,
    required this.onEditDose,
    required this.onClearForm,
    required this.onDismissKeyboard,
  });

  @override
  ConsumerState<DoseForm> createState() => _DoseFormState();
}

class _DoseFormState extends ConsumerState<DoseForm> with ControllerMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController();
  final _weightController = TextEditingController();
  final _dosePerKgController = TextEditingController();
  final _timeController = TextEditingController();
  final _dropSizeController = TextEditingController(text: '0.05');
  Dose? _selectedDose;
  Schedule? _selectedSchedule;
  final _notificationService = NotificationService();
  final Logger _logger = Logger('DoseForm');
  List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String _summary = '';
  MedicationType _medicationType = MedicationType.tablet;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _medicationType = MedicationType.values.firstWhere(
          (type) => type.toString().split('.').last == widget.medication.form.toLowerCase().replaceAll(' ', ''),
      orElse: () => MedicationType.tablet,
    );
    _updateSummary();
    setupListeners(
      [_amountController, _unitController, _weightController, _dosePerKgController, _timeController, _dropSizeController],
      _updateSummary,
    );
  }

  @override
  void dispose() {
    disposeControllers(
      [_amountController, _unitController, _weightController, _dosePerKgController, _timeController, _dropSizeController],
    );
    super.dispose();
  }

  void _updateSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final unit = _unitController.text;
    final time = _timeController.text;
    final days = _selectedDays;
    String? calculatedDose;
    if (amount > 0 && MedicationMatrix.isCalculationRequired(_medicationType)) {
      try {
        final dose = MedicationMatrix.calculateAdministrationDose(
          type: _medicationType,
          concentrationValue: widget.medication.concentration,
          concentrationUnit: widget.medication.concentrationUnit,
          desiredDose: amount,
          doseUnit: unit,
          dropSizeML: _medicationType == MedicationType.drops ? double.tryParse(_dropSizeController.text) ?? 0.05 : null,
        );
        calculatedDose = '${dose.toStringAsFixed(2)}${MedicationMatrix.getAdministrationUnits(_medicationType).first}';
      } catch (e) {
        calculatedDose = 'Calculation error';
      }
    }
    setState(() {
      _summary = Utils.formatSummary(
        name: '',
        amount: amount > 0 ? amount : null,
        unit: unit.isEmpty ? null : unit,
        form: 'daily',
        time: time.isEmpty ? null : time,
        days: days.isEmpty ? null : days,
        calculatedDose: calculatedDose,
      );
    });
  }

  void _calculateDose() {
    final weight = double.tryParse(_weightController.text);
    final dosePerKg = double.tryParse(_dosePerKgController.text);
    final unit = _unitController.text;

    if (weight == null || dosePerKg == null || unit.isEmpty || !MedicationMatrix.getAdministrationUnits(_medicationType).contains(unit)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid dose unit and enter weight and dose per kg')),
      );
      return;
    }

    try {
      final calculatedDose = MedCalculations.dosePerKg(weight, dosePerKg, unit);
      _amountController.text = MedCalculations.formatNumber(calculatedDose);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calculation error: $e')),
      );
    }
  }

  Future<void> _scheduleDose() async {
    if (!_formKey.currentState!.validate()) return;

    final time = _timeController.text;
    final amount = double.tryParse(_amountController.text);
    final unit = _unitController.text;
    final dropSize = _medicationType == MedicationType.drops ? double.tryParse(_dropSizeController.text) : null;

    if (time.isEmpty || amount == null || unit.isEmpty || !MedicationMatrix.getAdministrationUnits(_medicationType).contains(unit)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid dose unit and enter dose details and time')),
      );
      return;
    }

    if (_medicationType == MedicationType.drops && (dropSize == null || dropSize <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid drop size')),
      );
      return;
    }

    if (!MedicationMatrix.isValidValue(_medicationType, amount, 'administration')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose value out of valid range (0.01–999)')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final timeParts = time.split(':');
      if (timeParts.length != 2) throw FormatException('Invalid time format');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      _logger.info('Scheduling dose: amount=$amount, unit=$unit, time=$scheduledTime, days=$_selectedDays');

      final dose = DosesCompanion(
        medicationId: drift.Value(widget.medication.id),
        amount: drift.Value(amount),
        unit: drift.Value(unit),
        weight: double.tryParse(_weightController.text) != null
            ? drift.Value(double.parse(_weightController.text))
            : const drift.Value.absent(),
      );

      int doseId;
      if (_selectedDose == null) {
        doseId = await ref.read(driftServiceProvider).addDose(dose);
      } else {
        doseId = _selectedDose!.id;
        await ref.read(driftServiceProvider).updateDose(doseId, dose);
      }

      final schedule = SchedulesCompanion(
        doseId: drift.Value(doseId),
        frequency: drift.Value('daily'),
        days: drift.Value(_selectedDays),
        time: drift.Value(scheduledTime),
      );

      if (_selectedSchedule == null) {
        await ref.read(driftServiceProvider).addSchedule(schedule);
      } else {
        await ref.read(driftServiceProvider).deleteSchedule(_selectedSchedule!.id);
        await ref.read(driftServiceProvider).addSchedule(schedule);
      }

      final notificationId = '${widget.medication.id}_$doseId';
      _logger.info('Attempting to schedule notification: id=$notificationId');
      await _notificationService.cancelNotification(notificationId);
      await _notificationService.scheduleNotification(
        notificationId,
        'Take ${widget.medication.name}',
        'Dose: $amount $unit',
        scheduledTime,
        days: _selectedDays,
      );

      ref.invalidate(dosesProvider(widget.medication.id));
      widget.onClearForm();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose and notification scheduled')),
      );
      _logger.info('Dose scheduled successfully: doseId=$doseId');

      final doses = await ref.read(driftServiceProvider).getDoses(widget.medication.id);
      _logger.info('Retrieved doses after scheduling: $doses');
    } catch (e) {
      Navigator.pop(context);
      String errorMessage = 'Error scheduling dose: $e';
      if (e.toString().contains('exact_alarms_not_permitted')) {
        errorMessage = 'Please enable exact alarm permissions in app settings.';
      } else if (e.toString().contains('notifications_not_permitted')) {
        errorMessage = 'Please enable notifications in app settings.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      _logger.severe('Error scheduling dose: $e');
    }
  }

  void _editDose(Dose dose) async {
    try {
      final schedules = await ref.read(driftServiceProvider).getSchedules(dose.id);
      setState(() {
        _selectedDose = dose;
        _selectedSchedule = schedules.isNotEmpty ? schedules.first : null;
        _amountController.text = MedCalculations.formatNumber(dose.amount);
        _unitController.text = dose.unit;
        _weightController.text = dose.weight != 0.0 ? dose.weight.toString() : '';
        _dosePerKgController.text = '';
        _timeController.text = _selectedSchedule == null
            ? ''
            : '${_selectedSchedule!.time.hour.toString().padLeft(2, '0')}:${_selectedSchedule!.time.minute.toString().padLeft(2, '0')}';
        _selectedDays = _selectedSchedule != null
            ? List.from(_selectedSchedule!.days)
            : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        _updateSummary();
      });
      widget.onEditDose(dose);
      _logger.info('Editing dose: id=${dose.id}, amount=${dose.amount}, unit=${dose.unit}, time=${_timeController.text}, days=$_selectedDays');
    } catch (e) {
      _logger.severe('Error editing dose: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dose: $e')),
      );
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
            Text(
              _summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  FormWidgets.buildTextField(
                    controller: _amountController,
                    label: 'Amount',
                    helperText: 'Enter the dose amount',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Amount is required' : double.tryParse(value) == null ? 'Enter a valid number' : null,
                  ),
                  const SizedBox(height: 16),
                  FormWidgets.buildDropdown(
                    label: 'Unit',
                    helperText: 'Select the dose unit',
                    items: MedicationMatrix.getAdministrationUnits(_medicationType),
                    value: _unitController.text.isEmpty ? null : _unitController.text,
                    onChanged: (value) => setState(() => _unitController.text = value ?? ''),
                    validator: (value) => value == null ? 'Unit is required' : null,
                  ),
                  const SizedBox(height: 16),
                  FormWidgets.buildTextField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    helperText: 'Enter weight for dose calculation (optional)',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isNotEmpty && double.tryParse(value) == null ? 'Enter a valid number' : null,
                  ),
                  const SizedBox(height: 16),
                  FormWidgets.buildTextField(
                    controller: _dosePerKgController,
                    label: 'Dose per kg',
                    helperText: 'Enter dose per kg for calculation (optional)',
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isNotEmpty && double.tryParse(value) == null ? 'Enter a valid number' : null,
                  ),
                  if (_medicationType == MedicationType.drops) ...[
                    const SizedBox(height: 16),
                    FormWidgets.buildTextField(
                      controller: _dropSizeController,
                      label: 'Drop Size (mL)',
                      helperText: 'Enter drop size (e.g., 0.05 mL/drop)',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty ? 'Drop size is required' : double.tryParse(value) == null ? 'Enter a valid number' : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FormWidgets.buildTextField(
                    controller: _timeController,
                    label: 'Time (e.g., 08:00)',
                    helperText: 'Select the dose administration time',
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        _timeController.text = formattedTime;
                        _updateSummary();
                      }
                    },
                    validator: (value) => value!.isEmpty ? 'Time is required' : null,
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Days',
                      helperText: 'Select days for the dose schedule',
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                        return ChoiceChip(
                          label: Text(day),
                          selected: _selectedDays.contains(day),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                              _updateSummary();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateDose,
                    child: const Text('Calculate Dose'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _scheduleDose,
                    child: Text(_selectedDose == null ? 'Schedule Dose' : 'Update Dose'),
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