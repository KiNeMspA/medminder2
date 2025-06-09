import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../../services/dose_service.dart';

enum ScheduleView { list, day, week, month }

class SchedulesInfoScreen extends ConsumerStatefulWidget {
  const SchedulesInfoScreen({super.key});

  @override
  ConsumerState<SchedulesInfoScreen> createState() => _SchedulesInfoScreenState();
}

class _SchedulesInfoScreenState extends ConsumerState<SchedulesInfoScreen> {
  ScheduleView _currentView = ScheduleView.list;

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
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
        actions: [
          DropdownButton<ScheduleView>(
            value: _currentView,
            icon: const Icon(Icons.view_list, color: Colors.white),
            onChanged: (view) => setState(() => _currentView = view!),
            items: ScheduleView.values
                .map((view) => DropdownMenuItem(value: view, child: Text(view.toString().split('.').last)))
                .toList(),
          ),
        ],
      ),
      body: schedulesAsync.when(
        data: (schedules) =>
            schedules.isEmpty ? const Center(child: Text('No schedules')) : _buildView(context, ref, schedules),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/schedules/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildView(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    switch (_currentView) {
      case ScheduleView.list:
        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) => _buildScheduleRow(context, ref, schedules[index]),
        );
      case ScheduleView.day:
        return _buildDayView(context, ref, schedules);
      case ScheduleView.week:
        return _buildWeekView(context, ref, schedules);
      case ScheduleView.month:
        return _buildMonthView(context, ref, schedules);
    }
  }

  Widget _buildScheduleRow(BuildContext context, WidgetRef ref, Schedule schedule) {
    Future<String> _getDoseStatus(Schedule schedule, WidgetRef ref) async {
      final now = DateTime.now();
      final gracePeriod = const Duration(hours: 1); // TODO: Make editable in settings
      final scheduleTimeToday = DateTime(now.year, now.month, now.day, schedule.time.hour, schedule.time.minute);
      final isToday = schedule.frequency == 'Daily' || schedule.days.contains(_weekdayToString(now.weekday));
      if (!isToday) return 'Upcoming';
      if (scheduleTimeToday.add(gracePeriod).isAfter(now)) return 'Upcoming';
      // Placeholder: Check DoseHistory for Taken status
      final history = await ref.read(driftServiceProvider).getDoseHistory(schedule.doseId ?? -1);
      if (history.any((h) => h.takenAt.isAfter(scheduleTimeToday.subtract(const Duration(minutes: 1))))) {
        return 'Taken';
      }
// Placeholder: Check for Postponed/Cancelled
      return 'Missed';// Temporarily disable getDoseHistory call
    }

    return FutureBuilder<String>(
      future: _getDoseStatus(schedule, ref),
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'Upcoming';
        final statusColor = {
          'Taken': Colors.green,
          'Missed': Colors.red,
          'Postponed': Colors.orange,
          'Cancelled': Colors.red,
          'Upcoming': Colors.blue,
        }[status]!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ListTile(
            title: Text(schedule.medicationName),
            subtitle: Text(
              'Time: ${DateFormat.jm().format(schedule.time)}, Days: ${schedule.days.join(', ')}\nStatus: $status',
              style: TextStyle(color: statusColor),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(context, '/schedules/edit', arguments: schedule.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayView(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    final today = DateTime.now();
    final todaySchedules = schedules.where((s) => s.days.contains(_weekdayToString(today.weekday))).toList();
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Medication')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Status')),
        ],
        rows: todaySchedules.map((schedule) {
          return DataRow(cells: [
            DataCell(Text(schedule.medicationName)),
            DataCell(Text(DateFormat.jm().format(schedule.time))),
            DataCell(
              FutureBuilder<String>(
                future: _getDoseStatus(schedule, ref),
                builder: (context, snapshot) {
                  final status = snapshot.data ?? 'Upcoming';
                  final statusColor = {
                    'Taken': Colors.green,
                    'Missed': Colors.red,
                    'Postponed': Colors.orange,
                    'Cancelled': Colors.red,
                    'Upcoming': Colors.blue,
                  }[status]!;
                  return Text(status, style: TextStyle(color: statusColor));
                },
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Medication')),
          ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => DataColumn(label: Text(day))),
        ],
        rows: schedules.map((schedule) {
          return DataRow(cells: [
            DataCell(Text(schedule.medicationName)),
            ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => DataCell(
              schedule.days.contains(day)
                  ? FutureBuilder<String>(
                future: _getDoseStatus(schedule, ref),
                builder: (context, snapshot) {
                  final status = snapshot.data ?? 'Upcoming';
                  final statusColor = {
                    'Taken': Colors.green,
                    'Missed': Colors.red,
                    'Postponed': Colors.orange,
                    'Cancelled': Colors.red,
                    'Upcoming': Colors.blue,
                  }[status]!;
                  return Text(
                    DateFormat.jm().format(schedule.time),
                    style: TextStyle(color: statusColor),
                  );
                },
              )
                  : const Text('-'),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    return const Center(child: Text('Month view: TBD')); // Placeholder
  }

  String _weekdayToString(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}