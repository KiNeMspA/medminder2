import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';

class SchedulesInfoScreen extends ConsumerWidget {
  const SchedulesInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
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
      body: schedulesAsync.when(
        data: (schedules) => schedules.isEmpty
            ? const Center(child: Text('No schedules'))
            : ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: ListTile(
              title: Text(schedules[index].medicationName),
              subtitle: Text('Time: ${schedules[index].time.toString().substring(11, 16)}, Days: ${schedules[index].days.join(', ')}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(context, '/schedules/edit', arguments: schedules[index].id),
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
        onPressed: () => Navigator.pushNamed(context, '/schedules/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}