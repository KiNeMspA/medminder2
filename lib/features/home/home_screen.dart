import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../common/utils/formatters.dart';
import '../../data/database.dart';
import '../../services/drift_service.dart';
import '../../services/dose_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  void _showDoseDialog(BuildContext context, WidgetRef ref, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dose: ${schedule.medicationName}'),
        content: Text('Time: ${DateFormat.jm().format(schedule.time)}'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(doseServiceProvider).takeDose(
                schedule.medicationId,
                schedule.doseId!,
                1.0,
              );
              ref.invalidate(schedulesProvider);
              Navigator.pop(context);
            },
            child: const Text('Take', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(doseServiceProvider).snoozeDose(schedule.id);
              ref.invalidate(schedulesProvider);
              Navigator.pop(context);
            },
            child: const Text('Snooze', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(doseServiceProvider).cancelDose(schedule.id);
              ref.invalidate(schedulesProvider);
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final dosesAsync = ref.watch(allDosesProvider);
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder Dashboard'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming Doses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            schedulesAsync.when(
              data: (schedules) => schedules.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No schedules'),
              )
                  : FutureBuilder<List<Schedule>>(
                future: Future.wait(schedules.map((s) async {
                  final isAvailable = await ref.read(doseServiceProvider).isDoseAvailableToday(s);
                  return isAvailable ? s : null;
                })).then((list) => list.whereType<Schedule>().toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final upcoming = snapshot.data!;
                  if (upcoming.isEmpty) return const Text('No upcoming doses today');
                  return Column(
                    children: upcoming.map((schedule) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(schedule.medicationName),
                          subtitle: Text(
                            'Time: ${DateFormat.jm().format(schedule.time)}, Days: ${schedule.days.join(', ')}',
                          ),
                          onTap: schedule.doseId != null
                              ? () => _showDoseDialog(context, ref, schedule)
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorWidget(context, e.toString()),
            ),
            const SizedBox(height: 16),
            const Text('Medication Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            medicationsAsync.when(
              data: (meds) => meds.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No medications'),
              )
                  : Column(
                children: meds.map((med) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(med.name),
                    subtitle: Text(
                      'Stock: ${Utils.removeTrailingZeros(med.stockQuantity)} ${med.form == 'Tablet' || med.form == 'Capsule' ? med.form : med.concentrationUnit}',
                    ),
                    trailing: med.stockQuantity < 10
                        ? const Chip(label: Text('Low Stock'), backgroundColor: Colors.red)
                        : null,
                    onTap: () => Navigator.pushNamed(context, '/medications/edit', arguments: med.id),
                  ),
                )).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorWidget(context, e.toString()),
            ),
            const SizedBox(height: 16),
            const Text('Adherence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Weekly Adherence'),
                    subtitle: Text('Based on taken doses over the past 7 days'),
                  ),
                  SizedBox(
                    height: 200,
                    child: dosesAsync.when(
                      data: (doses) {
                        final takenDoses = doses.where((dose) => dose.taken).length;
                        final totalDoses = doses.length;
                        final adherence = totalDoses > 0 ? (takenDoses / totalDoses * 100).toInt() : 0;
                        return PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: adherence.toDouble(),
                                color: Colors.green,
                                title: '$adherence%',
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: (100 - adherence).toDouble(),
                                color: Colors.red,
                                title: '${100 - adherence}%',
                                radius: 50,
                              ),
                            ],
                            centerSpaceRadius: 40,
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
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

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}