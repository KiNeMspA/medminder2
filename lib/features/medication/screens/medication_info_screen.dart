import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/formatters.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../common/widgets/summary_card.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';

class MedicationsInfoScreen extends ConsumerWidget {
  const MedicationsInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
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
      body: medicationsAsync.when(
        data: (meds) => meds.isEmpty
            ? const Center(child: Text('No medications'))
            : ListView.builder(
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final med = meds[index];
            final qtyNum = med.stockQuantity;
            final medQtyUnit = med.form == 'Tablet'
                ? qtyNum > 1
                ? 'Tablets'
                : 'Tablet'
                : med.form == 'Capsule'
                ? qtyNum > 1
                ? 'Capsules'
                : 'Capsule'
                : 'mL';
            return Container(
              width: MediaQuery.of(context).size.width * 0.9, // Match SplitInputField
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/medications/overview', arguments: med.id),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12), // Compact padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${med.name} ${med.form}',
                              style: const TextStyle(
                                fontSize: 14, // Smaller for compactness
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Strength: ${Utils.removeTrailingZeros(med.concentration)}${med.concentrationUnit} per ${med.form == 'Tablet' ? 'Tablet' : med.form == 'Capsule' ? 'Capsule' : 'mL'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stock: ${Utils.removeTrailingZeros(med.stockQuantity)} $medQtyUnit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${Utils.removeTrailingZeros(med.concentration * med.stockQuantity)}${med.concentrationUnit}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => StandardDialog(
                            title: 'Delete Medication',
                            content: 'Are you sure you want to delete ${med.name}?',
                            onConfirm: () async {
                              await ref.read(driftServiceProvider).deleteMedication(med.id);
                              ref.invalidate(medicationsProvider);
                              Navigator.pop(context);
                            },
                            confirmText: 'Confirm',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/medications/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}