import 'package:flutter/material.dart';
import '../../../../common/medication_matrix.dart';
import '../../constants/medication_form_constants.dart';
import '../medication_form_field.dart';
import '../medication_form_card.dart';

class InjectionFields extends StatelessWidget {
  final TextEditingController concentrationController;
  final TextEditingController unitController;
  final TextEditingController volumeController;
  final TextEditingController powderAmountController;
  final TextEditingController solventVolumeController;
  final bool requiresReconstitution;
  final String? selectedSubType;
  final ValueChanged<bool> onReconstitutionChanged;
  final ValueChanged<String?> onUnitChanged;
  final double maxWidth;
  final bool excludeConcentration;

  const InjectionFields({
    super.key,
    required this.concentrationController,
    required this.unitController,
    required this.volumeController,
    required this.powderAmountController,
    required this.solventVolumeController,
    required this.requiresReconstitution,
    required this.selectedSubType,
    required this.onReconstitutionChanged,
    required this.onUnitChanged,
    required this.maxWidth,
    this.excludeConcentration = false,
  });

  void _incrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    controller.text = (currentValue + 0.1).toStringAsFixed(2);
  }

  void _decrementField(TextEditingController controller) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      controller.text = (currentValue - 0.1).toStringAsFixed(2);
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
                  helperText: MedicationFormConstants.getConcentrationHelpText(MedicationType.injection, selectedSubType),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty
                      ? MedicationFormConstants.concentrationRequiredMessage
                      : double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : double.parse(value) < 0.0001 || double.parse(value) > 999
                      ? 'Concentration out of range (0.0001–999)'
                      : null,
                  maxWidth: screenWidth * 0.9,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: unitController.text,
                  items: MedicationFormConstants.getConcentrationUnits(MedicationType.injection, selectedSubType)
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
        MedicationFormCard(
          child: Row(
            children: [
              Expanded(
                child: MedicationFormField(
                  controller: volumeController,
                  label: MedicationFormConstants.quantityLabel,
                  helperText: MedicationFormConstants.getQuantityHelpText(MedicationType.injection, selectedSubType),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty
                      ? MedicationFormConstants.quantityRequiredMessage
                      : double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : double.parse(value) < 0.01 || double.parse(value) > 999
                      ? 'Volume out of range (0.01–999)'
                      : null,
                  maxWidth: screenWidth * 0.9,
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.purple),
                    onPressed: () => _incrementField(volumeController),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, color: Colors.purple),
                    onPressed: () => _decrementField(volumeController),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (requiresReconstitution) ...[
          const SizedBox(height: MedicationFormConstants.fieldSpacing),
          MedicationFormCard(
            child: MedicationFormField(
              controller: powderAmountController,
              label: MedicationFormConstants.powderAmountLabel,
              helperText: 'Enter powder amount (mg)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => value!.isEmpty
                  ? MedicationFormConstants.reconstitutionRequiredMessage
                  : double.tryParse(value) == null
                  ? MedicationFormConstants.invalidNumberMessage
                  : double.parse(value) <= 0
                  ? 'Powder amount must be greater than 0'
                  : null,
              maxWidth: screenWidth * 0.9,
            ),
          ),
          const SizedBox(height: MedicationFormConstants.fieldSpacing),
          MedicationFormCard(
            child: MedicationFormField(
              controller: solventVolumeController,
              label: MedicationFormConstants.solventVolumeLabel,
              helperText: 'Enter solvent volume (mL)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => value!.isEmpty
                  ? MedicationFormConstants.reconstitutionRequiredMessage
                  : double.tryParse(value) == null
                  ? MedicationFormConstants.invalidNumberMessage
                  : double.parse(value) <= 0
                  ? 'Solvent volume must be greater than 0'
                  : null,
              maxWidth: screenWidth * 0.9,
            ),
          ),
        ],
      ],
    );
  }
}