import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

final driftServiceProvider = Provider<AppDatabase>((ref) => AppDatabase());

final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  return ref.watch(driftServiceProvider).getMedications();
});

final allDosesProvider = FutureProvider<List<Dose>>((ref) async {
  return ref.watch(driftServiceProvider).getAllDoses();
});

final schedulesProvider = FutureProvider<List<Schedule>>((ref) async {
  return ref.watch(driftServiceProvider).getAllSchedules();
});