import 'package:flutter/material.dart';
import '../../../../common/medication_matrix.dart';
import '../../constants/medication_form_constants.dart';
import '../medication_form_field.dart';

class TabletFields extends StatelessWidget {
  final TextEditingController concentrationController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final MedicationType selectedType;
  final ValueChanged<String?> onUnitChanged;
  final double maxWidth;

  const TabletFields({
    super.key,
    required this.concentrationController,
    required this.quantityController,
    required this.unitController,
    required this.selectedType,
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
    final quantity = double.tryParse(quantityController.text) ?? 1;
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
                helperText: 'Enter concentration per ${selectedType.name}',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty
                    ? MedicationFormConstants.concentrationRequiredMessage
                    : double.tryParse(value) == null
                    ? MedicationFormConstants.invalidNumberMessage
                    : null,
                maxWidth: screenWidth * 0.9, // Consistent width
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: unitController.text,
                items: MedicationMatrix.getConcentrationUnits(selectedType)
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onUnitChanged,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  helperText: 'Select unit', // Add helper text
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: MedicationFormConstants.fieldSpacing),
        MedicationFormField(
          controller: quantityController,
          label: MedicationFormConstants.quantityLabel,
          helperText: 'Enter number of ${quantity == 1 ? 'Tablet' : 'Tablets'}',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => value!.isEmpty
              ? MedicationFormConstants.quantityRequiredMessage
              : double.tryParse(value) == null
              ? MedicationFormConstants.invalidNumberMessage
              : null,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(quantity == 1 ? 'Tablet' : 'Tablets'),
              ),
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => _decrementField(quantityController),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => _incrementField(quantityController),
              ),
            ],
          ),
          maxWidth: screenWidth * 0.9, // Consistent width
        ),
      ],
    );
  }
}