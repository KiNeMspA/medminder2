// lib/features/medication/screens/medication_info_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/calculations.dart';
import '../../../common/utils/formatters.dart'; // Add import
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../../dose/screens/dose_screen.dart';
import 'medication_screen.dart';
import '../../schedule/screens/schedule_screen.dart';

class MedicationInfoScreen extends ConsumerWidget {
  final Medication medication;
  const MedicationInfoScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(dosesProvider(medication.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MedicationScreen(medication: medication)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text('Are you sure you want to delete this medication? This will also delete all associated doses and schedules.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(driftServiceProvider).deleteMedication(medication.id).then((_) {
                        ref.invalidate(medicationsProvider);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to HomeScreen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medication deleted')),
                        );
                      });
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Concentration: ${Utils.removeTrailingZeros(medication.concentration)} ${medication.concentrationUnit}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantity: ${Utils.removeTrailingZeros(medication.stockQuantity)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${medication.form}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Manage Doses',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoseScreen(medication: medication)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Add Schedule',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ScheduleScreen(medication: medication)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Schedules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Schedule>>(
                  future: ref.read(driftServiceProvider).getSchedules(medication.id),
                  builder: (context, scheduleSnapshot) {
                    if (scheduleSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final schedules = scheduleSnapshot.data ?? [];
                    if (schedules.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No schedules added',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: schedules.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        final time = DateFormat.jm().format(schedule.time);
                        final days = schedule.frequency == 'Daily' ? 'Daily' : schedule.days.join(', ');
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            '${schedule.name} - $days at $time',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: schedule.doseId == null
                              ? const Text(
                            'Warning: No dose assigned',
                            style: TextStyle(color: Colors.red),
                          )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (schedule.doseId != null)
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    final history = DoseHistoryCompanion(
                                      doseId: drift.Value(schedule.doseId!),
                                      takenAt: drift.Value(DateTime.now()),
                                    );
                                    ref.read(driftServiceProvider).addDoseHistory(history).then((_) {
                                      ref.read(driftServiceProvider).getDoses(medication.id).then((doses) {
                                        final dose = doses.firstWhere((d) => d.id == schedule.doseId);
                                        if (dose.unit == 'Tablet') {
                                          final newQuantity = medication.stockQuantity - dose.amount;
                                          if (newQuantity >= 0) {
                                            ref.read(driftServiceProvider).updateMedicationStock(medication.id, newQuantity);
                                            ref.invalidate(dosesProvider(medication.id));
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Insufficient stock')),
                                            );
                                            return;
                                          }
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Dose marked as taken')),
                                        );
                                      });
                                    });
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text('Are you sure you want to delete this schedule?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            ref.read(driftServiceProvider).deleteSchedule(schedule.id).then((_) {
                                              ref.invalidate(dosesProvider(medication.id));
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}