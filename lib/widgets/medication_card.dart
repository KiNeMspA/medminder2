// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          medication.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          stockText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.medication, color: Colors.blue),
              onPressed: onDoseTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  await ref.read(driftServiceProvider).deleteMedication(medication.id);
                  ref.invalidate(medicationsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Medication deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting medication: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}