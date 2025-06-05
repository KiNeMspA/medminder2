// lib/screens/medication_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/calculations.dart';
import '../data/database.dart';
import '../services/drift_service.dart';
import 'dose_screen.dart';
import 'medication_screen.dart';

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
                  'Concentration: ${medication.concentration} ${medication.concentrationUnit}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantity: ${medication.stockQuantity}',
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoseScreen(medication: medication)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Doses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                dosesAsync.when(
                  data: (doses) => doses.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No doses added',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: doses.map((dose) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: dose.name ?? 'Unnamed',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: ' - ${dose.amount} ${dose.unit == 'Tablet' ? 'Tablet${dose.amount == 1 ? '' : 's'}' : dose.unit} '
                                        '${dose.unit == 'Tablet' ? '(${MedCalculations.formatNumber(dose.amount * medication.concentration)} ${medication.concentrationUnit})' : ''}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: const Text('Are you sure you want to delete this dose?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          ref.read(driftServiceProvider).deleteDose(dose.id).then((_) {
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoseScreen(medication: medication),
                              ),
                            ),
                          ),
                          FutureBuilder<List<Schedule>>(
                            future: ref.read(driftServiceProvider).getSchedules(dose.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final schedules = snapshot.data ?? [];
                              if (schedules.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Schedules',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...schedules.map((schedule) {
                                      final time = DateFormat.jm().format(schedule.time);
                                      final days = schedule.frequency == 'Daily' ? 'Daily' : schedule.days.join(', ');
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        title: Text(
                                          '$days at $time',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check_circle, color: Colors.green),
                                              onPressed: () {
                                                final history = DoseHistoryCompanion(
                                                  doseId: Value(dose.id),
                                                  takenAt: Value(DateTime.now()),
                                                );
                                                ref.read(driftServiceProvider).addDoseHistory(history).then((_) {
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
                                    }),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}