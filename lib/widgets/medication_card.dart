// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import '../services/drift_service.dart';

class MedicationCard extends ConsumerWidget {
  final Medication medication;
  final VoidCallback onTap;
  final VoidCallback? onDoseTap;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTap,
    this.onDoseTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockText = '${medication.stockQuantity.toInt()} x ${medication.concentration}${medication.concentrationUnit} ${medication.form}${medication.stockQuantity == 1 ? '' : 's'} remaining';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          medication.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            FutureBuilder<List<Dose>>(
              future: ref.read(driftServiceProvider).getDoses(medication.id),
              builder: (context, doseSnapshot) {
                if (doseSnapshot.connectionState == ConnectionState.waiting || !doseSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final doses = doseSnapshot.data!;
                return FutureBuilder<List<Schedule>>(
                  future: Future.wait(doses.map((dose) => ref.read(driftServiceProvider).getSchedules(dose.id))),
                  builder: (context, scheduleSnapshot) {
                    if (scheduleSnapshot.connectionState == ConnectionState.waiting || !scheduleSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final allSchedules = scheduleSnapshot.data!.expand((schedules) => schedules).toList();
                    if (allSchedules.isEmpty) return const SizedBox.shrink();
                    final scheduleText = allSchedules
                        .map((s) => s.frequency == 'Daily'
                        ? 'Daily at ${DateFormat.jm().format(s.time)}'
                        : '${s.days.join(', ')} at ${DateFormat.jm().format(s.time)}')
                        .join('; ');
                    return Text(
                      'Schedules: $scheduleText',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    );
                  },
                );
              },
            ),
          ],
        ),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.medication, color: Colors.blue),
          onPressed: onDoseTap,
        ),
        contentPadding: const EdgeInsets.all(24),
      ),
    );
  }
}