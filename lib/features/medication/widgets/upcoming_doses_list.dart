import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/database.dart';
import '../constants/medication_ui_constants.dart';

class UpcomingDosesList extends ConsumerWidget {
  final int medicationId;

  const UpcomingDosesList({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return schedulesAsync.when(
      data: (schedules) {
        final upcoming = schedules
            .where((s) => s.medicationId == medicationId && s.time.isAfter(DateTime.now()))
            .take(3)
            .toList();
        return upcoming.isEmpty
            ? Card(
          elevation: 2,
          shape: MedicationUIConstants.cardShape,
          child: Padding(
            padding: MedicationUIConstants.cardPadding,
            child: const Text('No upcoming doses', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        )
            : Column(
          children: upcoming.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 20,
                child: Card(
                  elevation: 2,
                  shape: MedicationUIConstants.cardShape,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      schedule.medicationName,
                      style: MedicationUIConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Time: ${DateFormat.jm().format(schedule.time)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.schedule, color: MedicationUIConstants.secondaryColor),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}