// lib/features/history/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/formatters.dart'; // Add import
import '../../../data/database.dart';
import '../../../services/drift_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(allDosesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dose History')),
      body: dosesAsync.when(
        data: (doses) => doses.isEmpty
            ? const Center(child: Text('No dose history'))
            : ListView.builder(
          itemCount: doses.length,
          itemBuilder: (context, index) {
            final dose = doses[index];
            return FutureBuilder<List<Medication>>(
              future: ref.read(driftServiceProvider).getMedications(),
              builder: (context, medSnapshot) {
                final medication = medSnapshot.data?.firstWhere(
                      (m) => m.id == dose.medicationId,
                  orElse: () => Medication(
                    id: dose.medicationId,
                    name: 'Medication',
                    concentration: 0,
                    concentrationUnit: '',
                    stockQuantity: 0,
                    form: '',
                  ),
                );
                return FutureBuilder<List<Schedule>>(
                  future: ref.read(driftServiceProvider).getSchedules(dose.medicationId),
                  builder: (context, scheduleSnapshot) {
                    final schedules = scheduleSnapshot.data?.where((s) => s.doseId == dose.id).toList() ?? [];
                    final scheduleText = schedules.isEmpty
                        ? 'No schedules'
                        : schedules
                        .map((s) => '${s.name} - ${DateFormat.jm().format(s.time)} (${s.days.join(', ')})')
                        .join('; ');
                    return ListTile(
                      title: Text(
                        '${Utils.removeTrailingZeros(dose.amount)} ${dose.unit} (${medication?.name ?? ''})',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        'Medication ID: ${dose.medicationId}\n'
                            'Weight: ${dose.weight != 0.0 ? Utils.removeTrailingZeros(dose.weight) : 'N/A'} kg\n'
                            'Schedules: $scheduleText',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}