// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

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
            color: Colors.purple,
          ),
        ),
        subtitle: Text(
          stockText,
          style: Theme.of(context).textTheme.bodyLarge,
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