import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/formatters.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';

class DosesInfoScreen extends ConsumerWidget {
  const DosesInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dosesAsync = ref.watch(allDosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doses'),
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
      body: dosesAsync.when(
        data: (doses) => doses.isEmpty
            ? const Center(child: Text('No doses scheduled'))
            : ListView.builder(
          itemCount: doses.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: ListTile(
              title: Text(doses[index].name ?? 'Unnamed'),
              subtitle: Text('Amount: ${Utils.removeTrailingZeros(doses[index].amount)} ${doses[index].unit}, Medication ID: ${doses[index].medicationId}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(context, '/doses/edit', arguments: doses[index].id),
              ),
            ),
          ),
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
        onPressed: () => Navigator.pushNamed(context, '/doses/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}