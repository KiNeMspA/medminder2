// lib/screens/dose/dose_form.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:logging/logging.dart';
import '../../core/calculations.dart';
import '../../core/constants.dart';
import '../../data/database.dart';
import '../../services/drift_service.dart';
import '../../services/notification_service.dart';

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

class _DoseFormState extends ConsumerState<DoseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController();
  final _weightController = TextEditingController();
  final _dosePerKgController = TextEditingController();
  final _timeController = TextEditingController();
  Dose? _selectedDose;
  Schedule? _selectedSchedule;
  final _notificationService = NotificationService();
  final Logger _logger = Logger('DoseForm');
  List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _updateSummary();
    _amountController.addListener(_updateSummary);
    _unitController.addListener(_updateSummary);
    _weightController.addListener(_updateSummary);
    _dosePerKgController.addListener(_updateSummary);
    _timeController.addListener(_updateSummary);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateSummary);
    _unitController.removeListener(_updateSummary);
    _weightController.removeListener(_updateSummary);
    _dosePerKgController.removeListener(_updateSummary);
    _timeController.removeListener(_updateSummary);
    _amountController.dispose();
    _unitController.dispose();
    _weightController.dispose();
    _dosePerKgController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _updateSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final unit = _unitController.text.isEmpty ? '' : _unitController.text;
    final time = _timeController.text.isEmpty ? '' : _timeController.text;
    final days = _selectedDays.isEmpty ? '' : _selectedDays.join(', ');

    setState(() {
      _summary = amount > 0
          ? '${amount.toInt()} x ${amount}${unit} daily${time.isNotEmpty ? ' at $time' : ''}${days.isNotEmpty ? ' on $days' : ''}'
          : 'No dose specified';
    });
  }

  void _calculateDose() {
    final weight = double.tryParse(_weightController.text);
    final dosePerKg = double.tryParse(_dosePerKgController.text);
    final unit = _unitController.text;

    if (weight == null || dosePerKg == null || unit.isEmpty || !Units.doseUnits.contains(unit)) {
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

    if (time.isEmpty || amount == null || unit.isEmpty || !Units.doseUnits.contains(unit)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid dose unit and enter dose details and time')),
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
        _selectedDays = _selectedSchedule != null ? List.from(_selectedSchedule!.days) : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      helperText: "Enter the dose amount",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Amount is required';
                      if (double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _unitController.text.isEmpty ? null : _unitController.text,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      helperText: 'Select the dose unit (mg, mcg, IU)',
                    ),
                    items: Units.doseUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                    onChanged: (value) => setState(() => _unitController.text = value ?? ''),
                    validator: (value) => value == null ? 'Unit is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      helperText: 'Enter weight for dose calculation (optional)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isNotEmpty && double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosePerKgController,
                    decoration: const InputDecoration(
                      labelText: 'Dose per kg',
                      helperText: 'Enter dose per kg for calculation (optional)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isNotEmpty && double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time (e.g., 08:00)',
                      helperText: 'Select the dose administration time',
                    ),
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