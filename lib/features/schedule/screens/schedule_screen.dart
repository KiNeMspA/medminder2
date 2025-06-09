import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import '../../../common/mixins/controller_mixin.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../../services/notification_service.dart';
import '../constants/schedule_form_constants.dart';
import '../widgets/schedule_form_card.dart';
import '../widgets/schedule_form_field.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final Medication medication;

  const ScheduleScreen({super.key, required this.medication});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> with ControllerMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Logger _logger = Logger('ScheduleScreen');
  String _frequency = ScheduleFormConstants.defaultFrequency;
  List<String> _days = [];
  TimeOfDay _selectedTime = TimeOfDay.now();
  Dose? _selectedDose;

  @override
  void initState() {
    super.initState();
    setupListeners([_nameController], () => setState(() {}));
  }

  @override
  void dispose() {
    disposeControllers([_nameController]);
    super.dispose();
  }

  void _updateFrequency(String? value) {
    if (value != null) {
      setState(() {
        _frequency = value;
        _days = value == ScheduleFormConstants.dailyFrequency ? ScheduleFormConstants.daysOfWeek : [];
      });
    }
  }

  void _toggleDay(String day, bool selected) {
    setState(() {
      if (selected) _days.add(day);
      else _days.remove(day);
    });
  }

  void _updateTime(TimeOfDay? time) {
    if (time != null) setState(() => _selectedTime = time);
  }

  void _updateDose(Dose? dose) {
    if (dose != null) {
      setState(() {
        _selectedDose = dose;
        _nameController.text = dose.name ?? widget.medication.name;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate() || _selectedDose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dose')),
      );
      return;
    }
    if (_frequency == ScheduleFormConstants.weeklyFrequency && _days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ScheduleFormConstants.noDaysSelectedMessage)),
      );
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduleTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    final schedule = SchedulesCompanion(
      frequency: drift.Value(_frequency),
      days: drift.Value(_frequency == ScheduleFormConstants.dailyFrequency ? ScheduleFormConstants.daysOfWeek : _days),
      time: drift.Value(DateTime(1970, 1, 1, _selectedTime.hour, _selectedTime.minute)),
      name: drift.Value(_nameController.text),
      doseId: drift.Value(_selectedDose!.id),
    );

    try {
      final scheduleId = await ref.read(driftServiceProvider).addSchedule(schedule);
      final notificationService = NotificationService();
      await notificationService.scheduleNotification(
        'schedule_$scheduleId',
        ScheduleFormConstants.notificationTitle(widget.medication.name),
        ScheduleFormConstants.notificationBodyWithDose(_selectedDose!.amount, _selectedDose!.unit, _nameController.text),
        scheduleTime,
        days: _frequency == ScheduleFormConstants.dailyFrequency ? ScheduleFormConstants.daysOfWeek : _days,
      );
      await notificationService.logPendingNotifications();
      ref.invalidate(dosesProvider(widget.medication.id));
      ref.invalidate(schedulesProvider(widget.medication.id));
      ref.invalidate(medicationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ScheduleFormConstants.scheduleSavedMessage)),
      );
      Navigator.pop(context);
    } catch (e) {
      _logger.severe('Error saving schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is PlatformException && e.code == 'permissions_denied'
                ? 'Please grant alarm and notification permissions'
                : ScheduleFormConstants.errorSavingMessage(e),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ScheduleFormConstants.screenTitle(widget.medication.name)),
        flexibleSpace: Container(decoration: ScheduleFormConstants.appBarGradient(context)),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: ScheduleFormConstants.formPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScheduleFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ScheduleFormConstants.doseLabel, style: ScheduleFormConstants.sectionTitleStyle(context)),
                      const SizedBox(height: ScheduleFormConstants.innerSpacing),
                      FutureBuilder<List<Dose>>(
                        future: ref.read(driftServiceProvider).getDoses(widget.medication.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final doses = snapshot.data ?? [];
                          return DropdownButtonFormField<Dose>(
                            decoration: ScheduleFormConstants.dropdownDecoration('Select Dose (Required)'),
                            value: _selectedDose,
                            items: doses.map((dose) => DropdownMenuItem(
                              value: dose,
                              child: Text(ScheduleFormConstants.doseDisplay(dose)),
                            )).toList(),
                            onChanged: _updateDose,
                            validator: (value) => value == null ? 'Dose required' : null,
                            style: Theme.of(context).textTheme.bodyLarge,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ScheduleFormConstants.fieldSpacing),
                ScheduleFormCard(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: ScheduleFormConstants.textFieldDecoration(ScheduleFormConstants.nameLabel, ScheduleFormConstants.nameHelper),
                    validator: (value) => value!.isEmpty ? ScheduleFormConstants.nameRequiredMessage : null,
                  ),
                ),
                const SizedBox(height: ScheduleFormConstants.fieldSpacing),
                ScheduleFormCard(
                  child: DropdownButtonFormField<String>(
                    decoration: ScheduleFormConstants.dropdownDecoration(ScheduleFormConstants.frequencyLabel),
                    value: _frequency,
                    items: ScheduleFormConstants.frequencies
                        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: _updateFrequency,
                    validator: (value) => value == null ? ScheduleFormConstants.frequencyRequiredMessage : null,
                    style: Theme.of(context).textTheme.bodyLarge,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (_frequency == ScheduleFormConstants.weeklyFrequency) ...[
                  const SizedBox(height: ScheduleFormConstants.fieldSpacing),
                  ScheduleFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ScheduleFormConstants.daysLabel, style: ScheduleFormConstants.sectionTitleStyle(context)),
                        const SizedBox(height: ScheduleFormConstants.innerSpacing),
                        Wrap(
                          spacing: 8,
                          children: ScheduleFormConstants.daysOfWeek.map((day) {
                            final isSelected = _days.contains(day);
                            return ChoiceChip(
                              label: Text(day),
                              selected: isSelected,
                              onSelected: (selected) => _toggleDay(day, selected),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: ScheduleFormConstants.fieldSpacing),
                ScheduleFormCard(
                  child: ListTile(
                    title: Text(
                      ScheduleFormConstants.timeLabel(_selectedTime),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.grey),
                    contentPadding: ScheduleFormConstants.cardContentPadding,
                    onTap: () async => _updateTime(await showTimePicker(context: context, initialTime: _selectedTime)),
                  ),
                ),
                const SizedBox(height: ScheduleFormConstants.buttonSpacing),
                ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ScheduleFormConstants.buttonStyle,
                  child: Text(
                    ScheduleFormConstants.saveButton,
                    style: ScheduleFormConstants.buttonTextStyle(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}