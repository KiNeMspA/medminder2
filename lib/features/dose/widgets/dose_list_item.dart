import 'package:flutter/material.dart';
import '../../../common/utils/calculations.dart';
import '../../../data/database.dart';
import '../constants/dose_form_constants.dart';

class DoseListItem extends StatelessWidget {
  final Dose dose;
  final Medication medication;
  final bool isSelected;
  final Function(Dose) onTap;
  final VoidCallback onDelete;

  const DoseListItem({
    super.key,
    required this.dose,
    required this.medication,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: DoseFormConstants.cardElevation,
      shape: DoseFormConstants.cardShape,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: isSelected ? Colors.grey[100] : null,
      child: ListTile(
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: dose.name ?? DoseFormConstants.unnamedDose,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextSpan(
                text:
                ' - ${dose.amount} ${dose.unit == DoseFormConstants.tabletUnit ? 'Tablet${dose.amount == 1 ? '' : 's'}' : dose.unit} '
                    '${dose.unit == DoseFormConstants.tabletUnit ? '(${MedCalculations.formatNumber(dose.amount * medication.concentration)} ${medication.concentrationUnit})' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(DoseFormConstants.deleteDialogTitle),
              content: const Text(DoseFormConstants.deleteDialogContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(DoseFormConstants.cancelButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context);
                  },
                  child: const Text(DoseFormConstants.deleteButton),
                ),
              ],
            ),
          ),
        ),
        onTap: () => onTap(dose),
      ),
    );
  }
}