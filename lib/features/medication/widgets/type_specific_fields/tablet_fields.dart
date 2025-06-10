import 'package:flutter/material.dart';
import '../../../../common/medication_matrix.dart';
import '../../constants/medication_form_constants.dart';
import '../medication_form_field.dart';
import '../medication_form_card.dart';

class TabletFields extends StatelessWidget {
  final TextEditingController concentrationController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final MedicationType selectedType;
  final String? selectedSubType;
  final ValueChanged<String?> onUnitChanged;
  final double maxWidth;
  final bool excludeConcentration;

  const TabletFields({
    super.key,
    required this.concentrationController,
    required this.quantityController,
    required this.unitController,
    required this.selectedType,
    required this.selectedSubType,
    required this.onUnitChanged,
    required this.maxWidth,
    this.excludeConcentration = false,
  });

  void _incrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 1).toStringAsFixed(0);
  }

  void _decrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 1) {
      controller.text = (currentValue - 1).toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!excludeConcentration)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MedicationFormField(
                  controller: concentrationController,
                  label: MedicationFormConstants.concentrationLabel,
                  helperText: MedicationFormConstants.getConcentrationHelpText(selectedType, selectedSubType),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty
                      ? MedicationFormConstants.concentrationRequiredMessage
                      : double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : null,
                  maxWidth: screenWidth * 0.9,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: unitController.text,
                  items: MedicationFormConstants.getConcentrationUnits(selectedType, selectedSubType)
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
                ),
              ),
            ],
          ),
        const SizedBox(height: MedicationFormConstants.fieldSpacing),
        MedicationFormCard(
          child: Row(
            children: [
              Expanded(
                child: MedicationFormField(
                  controller: quantityController,
                  label: MedicationFormConstants.quantityLabel,
                  helperText: MedicationFormConstants.getQuantityHelpText(selectedType, selectedSubType),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty
                      ? MedicationFormConstants.quantityRequiredMessage
                      : double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : null,
                  maxWidth: screenWidth * 0.9,
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.purple),
                    onPressed: () => _incrementField(quantityController),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Colors.purple),
                    onPressed: () => _decrementField(quantityController),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}