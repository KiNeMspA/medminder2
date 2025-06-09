import 'package:flutter/material.dart';
import '../../constants/medication_form_constants.dart';
import '../medication_form_field.dart';

class InjectionFields extends StatefulWidget {
  final TextEditingController concentrationController;
  final TextEditingController unitController;
  final TextEditingController powderAmountController;
  final TextEditingController solventVolumeController;
  final TextEditingController totalLiquidController;
  final bool requiresReconstitution;
  final ValueChanged<bool> onReconstitutionChanged;
  final ValueChanged<String?> onUnitChanged;
  final double maxWidth;

  const InjectionFields({
    super.key,
    required this.concentrationController,
    required this.unitController,
    required this.powderAmountController,
    required this.solventVolumeController,
    required this.totalLiquidController,
    required this.requiresReconstitution,
    required this.onReconstitutionChanged,
    required this.onUnitChanged,
    required this.maxWidth,
  });

  @override
  InjectionFieldsState createState() => InjectionFieldsState();
}

class InjectionFieldsState extends State<InjectionFields> {
  String _deliveryMethod = 'Pre-filled Syringe';

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
        DropdownButtonFormField<String>(
          value: _deliveryMethod,
          items: ['Pre-filled Syringe', 'Vial']
              .map((method) => DropdownMenuItem(value: method, child: Text(method)))
              .toList(),
          onChanged: (value) => setState(() => _deliveryMethod = value!),
          decoration: InputDecoration(
            labelText: 'Delivery Method',
            helperText: 'Choose syringe or vial',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: MedicationFormConstants.fieldSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: MedicationFormField(
                controller: widget.concentrationController,
                label: 'Concentration',
                helperText: 'Enter concentration (mg or mcg)',
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
                value: widget.unitController.text,
                items: ['mg', 'mcg']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: widget.onUnitChanged,
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
        if (_deliveryMethod != 'Pre-filled Syringe') ...[
          const SizedBox(height: MedicationFormConstants.fieldSpacing),
          MedicationFormField(
            controller: widget.totalLiquidController,
            label: 'Total Volume',
            helperText: 'Enter total volume (mL)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) => value!.isEmpty
                ? 'Total volume required for vials'
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
                  onPressed: () => _decrementField(widget.totalLiquidController),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _incrementField(widget.totalLiquidController),
                ),
              ],
            ),
            maxWidth: screenWidth * 0.9,
          ),
        ],
        if (_deliveryMethod == 'Vial') ...[
          const SizedBox(height: MedicationFormConstants.fieldSpacing),
          CheckboxListTile(
            title: const Text('Requires Reconstitution'),
            value: widget.requiresReconstitution,
            onChanged: (value) => widget.onReconstitutionChanged(value!),
          ),
          if (widget.requiresReconstitution) ...[
            const SizedBox(height: MedicationFormConstants.fieldSpacing),
            MedicationFormField(
              controller: widget.powderAmountController,
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
            const SizedBox(height: MedicationFormConstants.fieldSpacing),
            MedicationFormField(
              controller: widget.solventVolumeController,
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
          ],
        ],
      ],
    );
  }
}