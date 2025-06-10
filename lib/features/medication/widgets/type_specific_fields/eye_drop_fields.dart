import 'package:flutter/material.dart';
import '../../../../common/medication_matrix.dart';
import '../../constants/medication_form_constants.dart';
import '../medication_form_field.dart';

class EyeDropFields extends StatelessWidget {
  final TextEditingController concentrationController;
  final TextEditingController volumeController;
  final TextEditingController unitController;
  final String? selectedSubType;
  final ValueChanged<String?> onUnitChanged;
  final double maxWidth;

  const EyeDropFields({
    super.key,
    required this.concentrationController,
    required this.volumeController,
    required this.unitController,
    required this.selectedSubType,
    required this.onUnitChanged,
    required this.maxWidth,
  });

  void _incrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }

  void _decrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 1).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: MedicationFormField(
                controller: concentrationController,
                label: MedicationFormConstants.concentrationLabel,
                helperText: MedicationFormConstants.getConcentrationHelpText(MedicationType.drops, selectedSubType),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty
                    ? MedicationFormConstants.concentrationRequiredMessage
                    : double.tryParse(value) == null
                    ? MedicationFormConstants.invalidNumberMessage
                    : double.parse(value) < 0.01 || double.parse(value) > 999
                    ? 'Concentration out of range (0.01–999)'
                    : null,
                maxWidth: screenWidth * 0.9,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: unitController.text,
                items: MedicationFormConstants.getConcentrationUnits(MedicationType.drops, selectedSubType)
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onUnitChanged,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  helperText: 'Select unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: MedicationFormConstants.fieldSpacing),
        MedicationFormField(
          controller: volumeController,
          label: MedicationFormConstants.quantityLabel,
          helperText: MedicationFormConstants.getQuantityHelpText(MedicationType.drops, selectedSubType),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => value!.isEmpty
              ? MedicationFormConstants.quantityRequiredMessage
              : double.tryParse(value) == null
              ? MedicationFormConstants.invalidNumberMessage
              : double.parse(value) < 0.01 || double.parse(value) > 999
              ? 'Volume out of range (0.01–999)'
              : null,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('mL'),
              ),
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => _decrementField(volumeController),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _incrementField(volumeController),
              ),
            ],
          ),
          maxWidth: screenWidth * 0.9,
        ),
      ],
    );
  }
}