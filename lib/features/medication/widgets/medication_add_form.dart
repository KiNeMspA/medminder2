import 'package:flutter/material.dart';
import 'package:medminder/features/medication/widgets/split_input_field.dart';
import '../../../common/constants/app_strings.dart';
import '../../../common/utils/formatters.dart';
import '../../../common/widgets/standard_dialog.dart';
import '../../../common/widgets/summary_card.dart';
import '../../../common/medication_matrix.dart';
import '../constants/medication_form_constants.dart';
import '../utils/medication_form_utils.dart';
import 'medication_form_card.dart';
import 'medication_form_field.dart';
import 'medication_form_widgets.dart';

class MedicationAddForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;
  final MedicationType selectedType;
  final String? selectedForm;
  final String? selectedSubType;
  final String unit;
  final bool requiresReconstitution;
  final int currentStep;
  final List<String> existingMedicationNames;
  final String summary;
  final void Function(MedicationType, String?, String?)? onTypeChanged;
  final ValueChanged<String?>? onUnitChanged;
  final ValueChanged<bool>? onReconstitutionChanged;
  final ValueChanged<String?>? onSubTypeChanged;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;

  const MedicationAddForm({
    super.key,
    required this.formKey,
    required this.controllers,
    required this.selectedType,
    this.selectedForm,
    this.selectedSubType,
    required this.unit,
    required this.requiresReconstitution,
    required this.currentStep,
    required this.existingMedicationNames,
    required this.summary,
    this.onTypeChanged,
    this.onUnitChanged,
    this.onReconstitutionChanged,
    this.onSubTypeChanged,
    this.onStepContinue,
    this.onStepCancel,
  });

  String _buildFormula() {
    final medName = controllers['name']!.text.isEmpty ? '[Name]' : controllers['name']!.text;
    final conc = controllers['concentration']!.text.isEmpty ? '[Conc]' : Utils.removeTrailingZeros(double.parse(controllers['concentration']!.text));
    final qty = controllers['quantity']!.text.isEmpty ? '1' : Utils.removeTrailingZeros(double.parse(controllers['quantity']!.text));
    final qtyNum = double.tryParse(qty) ?? 1;
    final medType = selectedForm ?? '[Type]';
    final pluralMedType = (medType == 'Tablet' || medType == 'Capsule') && qtyNum > 1 ? '${medType}s' : medType;
    final totalUnit = unit.isEmpty ? '[Unit]' : unit;
    final total = (double.tryParse(controllers['concentration']!.text) ?? 0) * (double.tryParse(controllers['quantity']!.text) ?? 0);
    final medQtyUnit = selectedType == MedicationType.drops || selectedType == MedicationType.injection
        ? 'mL'
        : selectedType == MedicationType.tablet
        ? 'Tablet' // Always singular for strength
        : 'Capsule';
    final stockQtyUnit = selectedType == MedicationType.drops || selectedType == MedicationType.injection
        ? 'mL'
        : selectedType == MedicationType.tablet
        ? qtyNum > 1
        ? 'Tablets'
        : 'Tablet'
        : qtyNum > 1
        ? 'Capsules'
        : 'Capsule';
    return '$medName|$pluralMedType|$conc $totalUnit per $medQtyUnit|$stockQtyUnit|$qty|${Utils.removeTrailingZeros(total)}$totalUnit|$totalUnit';
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (currentStep == 0) _buildTypeSelection(context),
          if (currentStep == 1) _buildNameField(context),
          if (currentStep == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SplitInputField(
                  labelText: MedicationFormConstants.concentrationLabel,
                  infoText: 'Enter the medication strength per ${selectedType == MedicationType.drops || selectedType == MedicationType.injection ? 'mL' : selectedType == MedicationType.tablet ? 'Tablet' : 'Capsule'}',
                  controller: controllers['concentration']!,
                  unit: unit,
                  unitOptions: MedicationFormConstants.getConcentrationUnits(selectedType, selectedSubType),
                  onUnitChanged: onUnitChanged,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty || double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : null,
                  maxWidth: maxWidth,
                ),
                const SizedBox(height: 16),
                SplitInputField(
                  labelText: selectedType == MedicationType.drops || selectedType == MedicationType.injection ? 'Volume' : 'Quantity',
                  infoText: selectedType == MedicationType.drops || selectedType == MedicationType.injection
                      ? 'Enter the total volume in stock'
                      : 'Enter the total number of ${selectedType == MedicationType.tablet ? 'Tablets' : 'Capsules'} in stock',
                  controller: selectedType == MedicationType.drops || selectedType == MedicationType.injection
                      ? controllers['volume']!
                      : controllers['quantity']!,
                  unit: selectedType == MedicationType.drops || selectedType == MedicationType.injection
                      ? 'mL'
                      : selectedType == MedicationType.tablet
                      ? 'Tablets'
                      : 'Capsules',
                  unitOptions: null, // No dropdown for Quantity/Volume
                  keyboardType: TextInputType.number,
                  isInteger: selectedType == MedicationType.tablet || selectedType == MedicationType.capsule,
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter a valid number';
                    final isInteger = selectedType == MedicationType.tablet || selectedType == MedicationType.capsule;
                    return (isInteger ? int.tryParse(value) : double.tryParse(value)) == null
                        ? MedicationFormConstants.invalidNumberMessage
                        : null;
                  },
                  maxWidth: maxWidth,
                ),
                if (requiresReconstitution) ...[
                  const SizedBox(height: 16),
                  MedicationFormCard(
                    child: SizedBox(
                      width: maxWidth,
                      child: MedicationFormField(
                        controller: controllers['powderAmount']!,
                        label: 'Powder Amount',
                        helperText: 'Enter powder amount in mg',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid number' : null,
                        maxWidth: maxWidth,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MedicationFormCard(
                    child: SizedBox(
                      width: maxWidth,
                      child: MedicationFormField(
                        controller: controllers['solventVolume']!,
                        label: 'Solvent Volume',
                        helperText: 'Enter solvent volume in ml',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid number' : null,
                        maxWidth: maxWidth,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final formulaParts = _buildFormula().split('|');
                    return SummaryCard(
                      medName: formulaParts[0],
                      medType: formulaParts[1],
                      strengthValue: formulaParts[2],
                      medQtyUnit: formulaParts[3],
                      medQty: formulaParts[4],
                      totalStrength: formulaParts[5],
                      unit: formulaParts[6],
                      maxWidth: maxWidth,
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Select the type of medication', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 16),
        MedicationFormWidgets.buildTypeSelector(
          context: context,
          value: selectedForm,
          onChanged: (String? newValue) {
            if (newValue != null && onTypeChanged != null) {
              final type = MedicationMatrix.formToType(newValue);
              onTypeChanged!(type, newValue, MedicationFormConstants.subTypes[type]?.first);
            }
          },
        ),
        const SizedBox(height: 24), // Added padding before buttons
        if (selectedForm == 'Injection' && MedicationFormConstants.subTypes[selectedType] != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Injection SubType', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: MedicationFormConstants.subTypes[selectedType]!.map((subType) {
                    final isSelected = selectedSubType == subType;
                    return ElevatedButton(
                      onPressed: () => onSubTypeChanged?.call(subType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(subType),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Please enter the name of the Medication', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24), // Increased from 16 to 24
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return existingMedicationNames.where(
                  (option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (String selection) {
                controllers['name']!.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controllers['name'],
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) => value!.isEmpty ? 'Medication name is required' : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConcentrationField(BuildContext context) {
    final fieldWidth = MediaQuery.of(context).size.width * 0.6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Enter the medication strength',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: Row(
            children: [
              SizedBox(
                width: fieldWidth * 0.5,
                child: TextFormField(
                  controller: controllers['concentration'],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: MedicationFormConstants.concentrationLabel,
                    labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => MedicationFormUtils().incrementField(controllers['concentration']!),
                          child: Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => MedicationFormUtils().decrementField(controllers['concentration']!),
                          child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                      ],
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty || double.tryParse(value) == null
                      ? MedicationFormConstants.invalidNumberMessage
                      : null,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey),
              SizedBox(
                width: fieldWidth * 0.5,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unit,
                    isExpanded: true,
                    items: MedicationFormConstants.getConcentrationUnits(selectedType, selectedSubType)
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(unit, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onUnitChanged,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    dropdownColor: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    icon: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}