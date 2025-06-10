import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../../../common/widgets/edit_field_dialog.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../data/database.dart';
import '../../../services/drift_service.dart';
import '../constants/medication_form_constants.dart';
import '../constants/medication_ui_constants.dart';
import '../utils/medication_utils.dart';
import '../widgets/doses_list.dart';
import '../widgets/medication_overview_card.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/upcoming_doses_list.dart';

class MedicationOverviewScreen extends ConsumerWidget {
  final int medicationId;

  const MedicationOverviewScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsync = ref.watch(medicationsProvider);

    return medicationAsync.when(
      data: (meds) {
        final med = meds.firstWhere((m) => m.id == medicationId);
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
        final type = MedicationMatrix.formToType(med.form);
        final subType = MedicationFormConstants.subTypes[type]?.contains(med.form) ?? false
            ? med.form
            : MedicationFormConstants.subTypes[type]?.first;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              med.name,
              style: MedicationUIConstants.bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.transparent,
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
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => MedicationUtils.showDeleteDialog(context, ref, med),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: MedicationUIConstants.sectionPadding,
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 300),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50,
                    child: widget,
                  ),
                  children: [
                    MedicationOverviewCard(
                      med: med,
                      medQtyUnit: medQtyUnit,
                      onEditName: () => MedicationUtils.showEditDialog(
                        context,
                        ref,
                        med,
                        'name',
                        'Medication Name',
                        med.name,
                      ),
                      onEditConcentration: () => MedicationUtils.showEditDialog(
                        context,
                        ref,
                        med,
                        'concentration',
                        'Concentration',
                        med.concentration.toString(),
                      ),
                      onEditStock: () => MedicationUtils.showEditDialog(
                        context,
                        ref,
                        med,
                        'stockQuantity',
                        'Stock Quantity',
                        med.stockQuantity.toString(),
                      ),
                      onTypeWarning: () => MedicationUtils.showTypeWarning(context),
                    ),
                    MedicationUIConstants.largeSpacing,
                    const Text(
                      'Upcoming Doses',
                      style: MedicationUIConstants.headerStyle,
                    ),
                    MedicationUIConstants.mediumSpacing,
                    UpcomingDosesList(medicationId: medicationId),
                    MedicationUIConstants.largeSpacing,
                    const Text(
                      'Doses',
                      style: MedicationUIConstants.headerStyle,
                    ),
                    MedicationUIConstants.mediumSpacing,
                    DosesList(medicationId: medicationId),
                    MedicationUIConstants.largeSpacing,
                    const Text(
                      'Schedule Calendar',
                      style: MedicationUIConstants.headerStyle,
                    ),
                    MedicationUIConstants.mediumSpacing,
                    ScheduleCalendar(medicationId: medicationId),
                    MedicationUIConstants.largeSpacing,
                    const Text(
                      'Dose History',
                      style: MedicationUIConstants.headerStyle,
                    ),
                    MedicationUIConstants.mediumSpacing,
                    Card(
                      elevation: 4,
                      shape: MedicationUIConstants.cardShape,
                      child: Padding(
                        padding: MedicationUIConstants.cardPadding,
                        child: const Text(
                          'Dose history list coming soon...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    MedicationUIConstants.largeSpacing,
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add Schedule', style: MedicationUIConstants.buttonTextStyle),
                      onPressed: () => MedicationUtils.showAddScheduleDialog(context, ref, medicationId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MedicationUIConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red)))),
    );
  }
}