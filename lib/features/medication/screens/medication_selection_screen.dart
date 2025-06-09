import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '/features/schedule/screens/schedule_screen.dart';

class MedicationSelectionScreen extends ConsumerWidget {
  const MedicationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Medication'),
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
      ),
      body: medicationsAsync.when(
        data: (meds) => meds.isEmpty
            ? const Center(child: Text('No medications added'))
            : ListView.builder(
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final med = meds[index];
            return ListTile(
              title: Text(med.name),
              subtitle: Text(
                '${Utils.removeTrailingZeros(med.stockQuantity)} x ${Utils.removeTrailingZeros(med.concentration)}${med.concentrationUnit} ${med.form}',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ScheduleScreen(medication: med)),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}