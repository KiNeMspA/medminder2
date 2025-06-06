// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';

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
    final stockText = '${medication.stockQuantity.toInt()} x ${medication.concentration}${medication.concentrationUnit} ${medication.form}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          medication.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stockText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            FutureBuilder<List<Schedule>>(
              future: ref.read(driftServiceProvider).getSchedules(medication.id),
              builder: (context, scheduleSnapshot) {
                print('Schedule snapshot for medication ${medication.id}: ${scheduleSnapshot.data}, state: ${scheduleSnapshot.connectionState}');
                if (scheduleSnapshot.connectionState == ConnectionState.waiting || !scheduleSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final allSchedules = scheduleSnapshot.data!;
                if (allSchedules.isEmpty) return const SizedBox.shrink();
                final scheduleText = allSchedules
                    .map((s) => s.frequency == 'Daily'
                    ? '${s.name} - Daily at ${DateFormat.jm().format(s.time)}'
                    : '${s.name} - ${s.days.join(', ')} at ${DateFormat.jm().format(s.time)}')
                    .join('; ');
                return Text(
                  'Schedules: $scheduleText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                );
              },
            ),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}