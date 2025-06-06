import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/dose_form_constants.dart';
import '../widgets/dose_form.dart';
import '../widgets/dose_list_item.dart';
import '../../../services/drift_service.dart';
import '../../../data/database.dart';

class DoseScreen extends ConsumerStatefulWidget {
  final Medication medication;
  const DoseScreen({super.key, required this.medication});

  @override
  _DoseScreenState createState() => _DoseScreenState();
}

class _DoseScreenState extends ConsumerState<DoseScreen> {
  Dose? _selectedDose;

  void _clearForm() => setState(() => _selectedDose = null);
  void _editDose(Dose dose) => setState(() => _selectedDose = dose);

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(dosesProvider(widget.medication.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(DoseFormConstants.screenTitle(widget.medication.name)),
        flexibleSpace: Container(
          decoration: DoseFormConstants.appBarGradient(context),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DoseForm(
              medication: widget.medication,
              onEditDose: _editDose,
              onClearForm: _clearForm,
              selectedDose: _selectedDose,
            ),
            const Divider(height: 1),
            dosesAsync.when(
              data: (doses) => doses.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(DoseFormConstants.noDosesMessage),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doses.length,
                itemBuilder: (context, index) => DoseListItem(
                  dose: doses[index],
                  medication: widget.medication,
                  isSelected: _selectedDose?.id == doses[index].id,
                  onTap: _editDose,
                  onDelete: () {
                    ref.read(driftServiceProvider)
                        .deleteDose(doses[index].id)
                        .then((_) => ref.invalidate(dosesProvider(widget.medication.id)));
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(DoseFormConstants.errorLoadingDoses(e))),
            ),
          ],
        ),
      ),
    );
  }
}