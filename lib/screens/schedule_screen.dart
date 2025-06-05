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
  final Dose dose;
  final Medication medication;

  const ScheduleScreen({super.key, required this.dose, required this.medication});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String _frequency = 'Daily';
  List<String> _days = [];
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule for ${widget.dose.name ?? 'Unnamed'}'),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_frequency == 'Weekly' && _days.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one day')),
                    );
                    return;
                  }

                  final schedule = SchedulesCompanion(
                    doseId: drift.Value(widget.dose.id),
                    frequency: drift.Value(_frequency),
                    days: drift.Value(_frequency == 'Daily' ? _daysOfWeek : _days),
                    time: drift.Value(DateTime.now().copyWith(
                      hour: _selectedTime.hour,
                      minute: _selectedTime.minute,
                    )),
                  );

                  try {
                    await ref.read(driftServiceProvider).addSchedule(schedule);
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
                      'dose_${widget.dose.id}',
                      'Medication Reminder: ${widget.medication.name}',
                      'Time to take ${widget.dose.amount} ${widget.dose.unit} of ${widget.dose.name ?? 'Unnamed'}',
                      tzTime,
                      days: _frequency == 'Daily' ? _daysOfWeek : _days,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule saved')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
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