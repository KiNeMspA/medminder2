import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../../services/notification_service.dart';
import '../../medication/constants/medication_form_constants.dart';

class SchedulesEditScreen extends ConsumerStatefulWidget {
  final int scheduleId;
  const SchedulesEditScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<SchedulesEditScreen> createState() => _SchedulesEditScreenState();
}

class _SchedulesEditScreenState extends ConsumerState<SchedulesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedMedicationId;
  String? _selectedMedicationName;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedDays = [];
  bool _notificationsEnabled = true;
  int _currentStep = 0;
  List<Medication> _medications = [];
  Schedule? _schedule;

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _loadSchedule();
  }

  Future<void> _loadMedications() async {
    final meds = await ref.read(driftServiceProvider).getMedications();
    setState(() {
      _medications = meds;
    });
  }

  Future<void> _loadSchedule() async {
    final schedule = await ref.read(driftServiceProvider).getScheduleById(widget.scheduleId);
    if (schedule != null) {
      setState(() {
        _schedule = schedule;
        _selectedMedicationId = schedule.medicationId;
        _selectedMedicationName = schedule.medicationName;
        _selectedTime = TimeOfDay.fromDateTime(schedule.time);
        _selectedDays = schedule.days;
        _notificationsEnabled = schedule.notificationsEnabled;
      });
    }
  }

  String get _summary {
    if (_selectedMedicationName == null || _selectedDays.isEmpty) return '';
    return 'Schedule: $_selectedMedicationName at ${_selectedTime.format(context)} on ${_selectedDays.join(', ')}';
  }

  void _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMedicationId == null || _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medication and days')),
      );
      return;
    }

    final schedule = SchedulesCompanion(
      id: drift.Value(widget.scheduleId),
      medicationId: drift.Value(_selectedMedicationId!),
      medicationName: drift.Value(_selectedMedicationName!),
      time: drift.Value(DateTime.now().copyWith(hour: _selectedTime.hour, minute: _selectedTime.minute)),
      days: drift.Value(_selectedDays),
      notificationsEnabled: drift.Value(_notificationsEnabled),
      notificationId: drift.Value(_schedule?.notificationId ?? '${_selectedMedicationId}_${DateTime.now().millisecondsSinceEpoch}'),
    );

    try {
      await ref.read(driftServiceProvider).updateSchedule(widget.scheduleId, schedule);
      if (_notificationsEnabled && schedule.notificationId.value != null) {
        await ref.read(notificationServiceProvider).scheduleNotification(
          id: schedule.notificationId.value!,
          title: 'MedMinder: $_selectedMedicationName',
          body: 'Time for your dose!',
          scheduledTime: DateTime.now().copyWith(hour: _selectedTime.hour, minute: _selectedTime.minute),
          days: _selectedDays,
        );
      } else if (!_notificationsEnabled && _schedule?.notificationId != null) {
        await ref.read(notificationServiceProvider).cancelNotification(_schedule!.notificationId!);
      }
      ref.invalidate(schedulesProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule updated')),
      );
    } catch (e, stack) {
      debugPrint('Update error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating schedule: $e')),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Select Medication'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medications.map((med) {
                return ChoiceChip(
                  label: Text(med.name),
                  selected: _selectedMedicationId == med.id,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMedicationId = med.id;
                        _selectedMedicationName = med.name;
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
        title: const Text('Schedule Time'),
        content: ElevatedButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
          child: Text('Select Time: ${_selectedTime.format(context)}'),
        ),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Select Days'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
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
                });
              },
            );
          }).toList(),
        ),
        isActive: _currentStep == 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Notifications'),
        content: SwitchListTile(
          title: const Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (value) => setState(() {
            _notificationsEnabled = value;
          }),
        ),
        isActive: _currentStep == 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Confirm'),
        content: Text(_summary.isEmpty ? 'Please complete all steps' : _summary),
        isActive: _currentStep == 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_schedule == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
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
                      if (_currentStep == 0 && _selectedMedicationId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a medication')),
                        );
                        return;
                      }
                      if (_currentStep == 2 && _selectedDays.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one day')),
                        );
                        return;
                      }
                      if (_currentStep < _buildSteps().length - 1) {
                        setState(() => _currentStep += 1);
                      } else {
                        _saveSchedule();
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