import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../../services/notification_service.dart';
import '../../medication/constants/medication_form_constants.dart';

class SchedulesAddScreen extends ConsumerStatefulWidget {
  final int? medicationId;

  const SchedulesAddScreen({super.key, this.medicationId});

  @override
  ConsumerState<SchedulesAddScreen> createState() => _SchedulesAddScreenState();
}

class _SchedulesAddScreenState extends ConsumerState<SchedulesAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int? _selectedMedicationId;
  String? _selectedMedicationName;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedDays = [];
  bool _notificationsEnabled = true;
  int? _selectedDoseId;
  int _currentStep = 0;
  List<Medication> _medications = [];
  List<Dose> _doses = [];
  final Logger _logger = Logger('SchedulesAddScreen');

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing SchedulesAddScreen with medicationId: ${widget.medicationId}');
    if (widget.medicationId != null) {
      _selectedMedicationId = widget.medicationId;
      _loadMedications().then((_) {
        final med = _medications.firstWhere(
              (m) => m.id == widget.medicationId!,
          orElse: () => Medication(id: -1, name: 'Not Found', concentration: 0, concentrationUnit: '', stockQuantity: 0, form: ''),
        );
        if (med.id != -1) {
          setState(() {
            _selectedMedicationId = med.id;
            _selectedMedicationName = med.name;
            _logger.info('Pre-selected medication: ${med.name} (ID: ${med.id})');
          });
          _loadDoses();
        } else {
          _logger.severe('Medication ID ${widget.medicationId} not found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication not found')),
          );
        }
      });
    } else {
      _loadMedications();
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    final meds = await ref.read(driftServiceProvider).getMedications();
    setState(() {
      _medications = meds;
    });
    if (_selectedMedicationId != null) {
      _loadDoses();
    }
  }

  Future<void> _loadDoses() async {
    if (_selectedMedicationId == null) return;
    final doses = await ref.read(driftServiceProvider).getDoses(_selectedMedicationId!);
    setState(() {
      _doses = doses;
    });
  }

  String get _summary {
    if (_selectedMedicationName == null || _selectedDays.isEmpty) return '';
    final doseText = _selectedDoseId != null ? 'Dose ID: $_selectedDoseId, ' : '';
    return 'Schedule: $_selectedMedicationName at ${_selectedTime.format(context)} on ${_selectedDays.join(', ')}\n$doseText: ${_nameController.text.isEmpty ? 'Unnamed' : _nameController.text}';
  }

  void _saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all required fields')));
      return;
    }

    if (_selectedMedicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a medication')));
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day')));
      return;
    }

    final notificationId = '${_selectedMedicationId}_${DateTime.now().millisecondsSinceEpoch}';
    final schedule = SchedulesCompanion(
      medicationId: drift.Value(_selectedMedicationId!),
      medicationName: drift.Value(_selectedMedicationName!),
      frequency: drift.Value('Daily'),
      time: drift.Value(DateTime.now().copyWith(hour: _selectedTime.hour, minute: _selectedTime.minute)),
      days: drift.Value(_selectedDays),
      name: drift.Value(_nameController.text.isEmpty ? 'Unnamed' : _nameController.text),
      doseId: _selectedDoseId != null ? drift.Value(_selectedDoseId!) : const drift.Value.absent(),
      notificationsEnabled: drift.Value(_notificationsEnabled),
      notificationId: drift.Value(notificationId),
    );

    try {
      _logger.info('Saving schedule: $schedule');
      final scheduleId = await ref.read(driftServiceProvider).addSchedule(schedule);
      if (_notificationsEnabled) {
        await ref
            .read(notificationServiceProvider)
            .scheduleNotification(
              id: notificationId,
              title: 'MedMinder: $_selectedMedicationName',
              body: 'Time for your dose!',
              scheduledTime: DateTime.now().copyWith(hour: _selectedTime.hour, minute: _selectedTime.minute),
              days: _selectedDays,
            );
        _logger.info('Scheduled notification for schedule ID: $scheduleId');
      }
      ref.invalidate(schedulesProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule added')));
    } catch (e, stack) {
      _logger.severe('Error adding schedule: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding schedule: $e')));
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
                        _selectedDoseId = null;
                        _doses = [];
                      });
                      _loadDoses();
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
        title: const Text('Select Dose (Optional)'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedDoseId,
              items: [
                const DropdownMenuItem<int>(value: null, child: Text('None')),
                ..._doses.map(
                  (dose) => DropdownMenuItem<int>(
                    value: dose.id,
                    child: Text('${dose.amount} ${dose.unit} (${dose.name ?? 'Unnamed'})'),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDoseId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Dose', border: OutlineInputBorder()),
            ),
          ],
        ),
        isActive: _currentStep == 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Schedule Name'),
        content: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Schedule Name',
            hintText: 'e.g., Morning Dose',
            border: OutlineInputBorder(),
          ),
        ),
        isActive: _currentStep == 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Schedule Time'),
        content: ElevatedButton(
          onPressed: () async {
            final time = await showTimePicker(context: context, initialTime: _selectedTime);
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
            }
          },
          child: Text('Select Time: ${_selectedTime.format(context)}'),
        ),
        isActive: _currentStep == 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
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
        isActive: _currentStep == 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
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
        isActive: _currentStep == 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Confirm'),
        content: Text(_summary.isEmpty ? 'Please complete all steps' : _summary),
        isActive: _currentStep == 6,
        state: _currentStep > 6 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Please select a medication')));
                        return;
                      }
                      if (_currentStep == 4 && _selectedDays.isEmpty) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Please select at least one day')));
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
                              TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
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