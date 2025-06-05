// lib/screens/schedule_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/database.dart';
import '../services/drift_service.dart';
import '../services/notification_service.dart';
import '../widgets/form_widgets.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final Medication medication;

  const ScheduleScreen({super.key, required this.medication});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _frequency = 'Daily';
  List<String> _days = [];
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Dose> _selectedDoses = [];
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    print('Building ScheduleScreen for medication ${widget.medication.id}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule for ${widget.medication.name}'),
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
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: InputBorder.none,
                    ),
                    value: _frequency,
                    items: ['Daily', 'Weekly']
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _frequency = value!;
                        if (_frequency == 'Daily') {
                          _days = _daysOfWeek;
                        } else {
                          _days = [];
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Frequency is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_frequency == 'Weekly')
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Days',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _daysOfWeek.map((day) {
                            final isSelected = _days.contains(day);
                            return ChoiceChip(
                              label: Text(day),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _days.add(day);
                                  } else {
                                    _days.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    'Time: ${DateFormat.jm().format(DateTime(2023, 1, 1, _selectedTime.hour, _selectedTime.minute))}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () async {
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
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doses',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Dose>>(
                        future: ref.read(driftServiceProvider).getDoses(widget.medication.id),
                        builder: (context, snapshot) {
                          print('Doses snapshot: ${snapshot.data}, state: ${snapshot.connectionState}');
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final doses = snapshot.data ?? [];
                          if (doses.isEmpty) {
                            return const Text('No doses available');
                          }
                          return Wrap(
                            spacing: 8,
                            children: doses.map((dose) {
                              final isSelected = _selectedDoses.contains(dose);
                              return ChoiceChip(
                                label: Text(
                                  '${dose.amount} ${dose.unit == 'Tablet' ? 'Tablet${dose.amount == 1 ? '' : 's'}' : dose.unit}',
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDoses.add(dose);
                                    } else {
                                      _selectedDoses.remove(dose);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    print('Form validation failed');
                    return;
                  }
                  if (_frequency == 'Weekly' && _days.isEmpty) {
                    print('No days selected for Weekly schedule');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one day')),
                    );
                    return;
                  }
                  if (_selectedDoses.isEmpty) {
                    print('No doses selected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one dose')),
                    );
                    return;
                  }

                  print('Saving schedule with doses: ${_selectedDoses.map((d) => d.id).toList()}');
                  final schedule = SchedulesCompanion(
                    frequency: drift.Value(_frequency),
                    days: drift.Value(_frequency == 'Daily' ? _daysOfWeek : _days),
                    time: drift.Value(DateTime.now().copyWith(
                      hour: _selectedTime.hour,
                      minute: _selectedTime.minute,
                    )),
                  );

                  try {
                    final scheduleId = await ref.read(driftServiceProvider).addSchedule(schedule);
                    for (final dose in _selectedDoses) {
                      final scheduleDose = ScheduleDosesCompanion(
                        scheduleId: drift.Value(scheduleId),
                        doseId: drift.Value(dose.id),
                      );
                      await ref.read(driftServiceProvider).addScheduleDose(scheduleDose);
                    }
                    final notificationService = NotificationService();
                    final tzTime = tz.TZDateTime.from(
                      DateTime.now().copyWith(
                        hour: _selectedTime.hour,
                        minute: _selectedTime.minute,
                        second: 0,
                        millisecond: 0,
                        microsecond: 0,
                      ),
                      tz.local,
                    );
                    await notificationService.scheduleNotification(
                      'schedule_${scheduleId}',
                      'Medication Reminder: ${widget.medication.name}',
                      'Time to take ${_selectedDoses.map((dose) => '${dose.amount} ${dose.unit}').join(', ')}',
                      tzTime,
                      days: _frequency == 'Daily' ? _daysOfWeek : _days,
                    );
                    print('Schedule saved with ID: $scheduleId');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule saved')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error saving schedule: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving schedule: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Save Schedule',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}