// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dose/screens/dose_screen.dart';
import '../history/screens/history_screen.dart';
import '../medication/screens/add_medication_screen.dart';
import '../medication/screens/medication_info_screen.dart';
import '../medication/screens/medication_screen.dart';
import '../../services/drift_service.dart';
import 'widgets/medication_card.dart';
import '../../data/database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder'),
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
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await ref.read(driftServiceProvider).copyDatabaseToPublicDirectory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database copied to Download folder')),
              );
            },
            tooltip: 'Copy Database',
          ),
        ],
      ),
      body: medicationsAsync.when(
        data: (meds) => meds.isEmpty
            ? const Center(child: Text('No medications added'))
            : ListView.builder(
          itemCount: meds.length,
          itemBuilder: (context, index) {
            final med = meds[index];
            return MedicationCard(
              medication: med,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MedicationInfoScreen(medication: med)),
              ),
              onDoseTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DoseScreen(medication: med)),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
        ).then((_) => ref.invalidate(medicationsProvider)),
        child: const Icon(Icons.add),
      ),
    );
  }
}