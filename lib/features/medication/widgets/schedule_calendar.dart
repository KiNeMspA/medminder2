import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/database.dart';
import '../constants/medication_ui_constants.dart';

class ScheduleCalendar extends ConsumerWidget {
  final int medicationId;

  const ScheduleCalendar({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Card(
      elevation: 4,
      shape: MedicationUIConstants.cardShape,
      child: Container(
        height: MedicationUIConstants.calendarHeight,
        decoration: BoxDecoration(
          borderRadius: MedicationUIConstants.cardRadius,
          gradient: MedicationUIConstants.cardGradient,
        ),
        child: Padding(
          padding: MedicationUIConstants.cardPadding,
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              return schedulesAsync.whenData((schedules) => schedules
                  .where((s) =>
              s.medicationId == medicationId &&
                  s.time.day == day.day &&
                  s.time.month == day.month &&
                  s.time.year == day.year)
                  .toList())
                  .value ??
                  [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: MedicationUIConstants.secondaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: MedicationUIConstants.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: MedicationUIConstants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (schedulesAsync.value != null) {
                final daySchedules = schedulesAsync.value!
                    .where((s) =>
                s.medicationId == medicationId &&
                    s.time.day == selectedDay.day &&
                    s.time.month == selectedDay.month &&
                    s.time.year == selectedDay.year)
                    .toList();
                if (daySchedules.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => Padding(
                      padding: MedicationUIConstants.cardPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedules for ${DateFormat.yMMMd().format(selectedDay)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          MedicationUIConstants.mediumSpacing,
                          ...daySchedules.map((s) => ListTile(
                            title: Text(s.medicationName),
                            subtitle: Text('Time: ${DateFormat.jm().format(s.time)}'),
                          )),
                        ],
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}