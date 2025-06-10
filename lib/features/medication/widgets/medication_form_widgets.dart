import 'package:flutter/material.dart';
import '../../../common/form_styles.dart';
import '../../../common/medication_matrix.dart';
import '../constants/medication_form_constants.dart';
import '../utils/medication_form_utils.dart';
import 'medication_form_field.dart';
import 'medication_form_card.dart';
import 'type_specific_fields/tablet_fields.dart';
import 'type_specific_fields/injection_fields.dart';
import 'type_specific_fields/eye_drop_fields.dart';

class MedicationFormWidgets {
  static Widget buildTypeSelector({
    required BuildContext context,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: MedicationFormConstants.forms.map((form) {
            final isSelected = value == form;
            return SizedBox(
              width: 90, // Smaller width
              height: 36, // Smaller height
              child: ElevatedButton(
                onPressed: () => onChanged(form),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                  // Smaller font
                  elevation: 2, // Subtle shadow
                ),
                child: Text(form, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget buildNameField({
    required BuildContext context,
    required TextEditingController controller,
    required double maxWidth,
  }) {
    return MedicationFormCard(
      child: MedicationFormField(
        controller: controller,
        label: MedicationFormConstants.nameLabel,
        helperText: 'Enter the name of the medication',
        helperMaxLines: 2,
        validator: (value) => value!.isEmpty ? MedicationFormConstants.nameRequiredMessage : null,
        maxWidth: maxWidth,
      ),
    );
  }

  static Widget buildConcentrationField({
    required BuildContext context,
    required TextEditingController controller,
    required MedicationType selectedType,
    required String? selectedSubType,
    required String unit,
    required ValueChanged<String?>? onUnitChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required double maxWidth,
  }) {
    return MedicationFormCard(
      child: MedicationFormField(
        controller: controller,
        label: MedicationFormConstants.concentrationLabel,
        helperText: MedicationFormConstants.getConcentrationHelpText(selectedType, selectedSubType),
        helperMaxLines: 2,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => value!.isEmpty
            ? MedicationFormConstants.concentrationRequiredMessage
            : double.tryParse(value) == null
            ? MedicationFormConstants.invalidNumberMessage
            : null,
        suffix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: unit,
                items: MedicationFormConstants.getConcentrationUnits(
                  selectedType,
                  selectedSubType,
                ).map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: onUnitChanged,
              ),
            ),
            _buildIconButton(Icons.arrow_upward, onIncrement, color: Colors.purple),
            _buildIconButton(Icons.arrow_downward, onDecrement, color: Colors.purple),
          ],
        ),
        maxWidth: maxWidth,
      ),
    );
  }

  static Widget buildTypeSpecificFields({
    required BuildContext context,
    required MedicationType type,
    required String? subType,
    required TextEditingController concentrationController,
    required TextEditingController quantityController,
    required TextEditingController volumeController,
    required TextEditingController unitController,
    required TextEditingController powderAmountController,
    required TextEditingController solventVolumeController,
    required bool requiresReconstitution,
    ValueChanged<bool>? onReconstitutionChanged,
    ValueChanged<String?>? onUnitChanged,
    required double maxWidth,
    bool excludeConcentration = false,
  }) {
    final fieldWidth = maxWidth * 0.6;
    final medQty = type == MedicationType.tablet
        ? 'Tablets'
        : type == MedicationType.capsule
        ? 'Capsules'
        : type == MedicationType.injection
        ? 'Injections'
        : 'Drops';
    final quantityField = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Please enter the total number of $medQty in stock',
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
                  controller: quantityController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    labelStyle: const TextStyle(fontSize: 14),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => MedicationFormUtils().incrementField(quantityController, isInteger: true),
                          child: Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => MedicationFormUtils().decrementField(quantityController, isInteger: true),
                          child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                      ],
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty || int.tryParse(value) == null ? 'Enter a valid number' : null,
                ),
              ),
              if (type == MedicationType.tablet || type == MedicationType.capsule)
                SizedBox(
                  width: fieldWidth * 0.5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey)),
                    ),
                    child: Text(
                      medQty,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final volumeField = type == MedicationType.drops || type == MedicationType.injection
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Please enter the total volume in stock',
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
                  controller: volumeController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Volume',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    labelStyle: const TextStyle(fontSize: 14),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => MedicationFormUtils().incrementField(volumeController),
                          child: Icon(
                            Icons.arrow_upward,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => MedicationFormUtils().decrementField(volumeController),
                          child: Icon(
                            Icons.arrow_downward,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid number' : null,
                ),
              ),
              SizedBox(
                width: fieldWidth * 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey)),
                  ),
                  child: const Text(
                    'mL',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    )
        : const SizedBox.shrink();

    switch (type) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [quantityField]);
      case MedicationType.injection:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            volumeField,
            const SizedBox(height: 16),
            if (requiresReconstitution) ...[
              MedicationFormCard(
                child: SizedBox(
                  width: fieldWidth,
                  child: MedicationFormField(
                    controller: powderAmountController,
                    label: 'Powder Amount',
                    helperText: 'Powder amount in mg',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid number' : null,
                    maxWidth: fieldWidth,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MedicationFormCard(
                child: SizedBox(
                  width: fieldWidth,
                  child: MedicationFormField(
                    controller: solventVolumeController,
                    label: 'Solvent Volume',
                    helperText: 'Solvent volume in ml',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty || double.tryParse(value) == null ? 'Enter a valid number' : null,
                    maxWidth: fieldWidth,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            CheckboxListTile(
              title: const Text('Requires Reconstitution'),
              value: requiresReconstitution,
              onChanged: onReconstitutionChanged != null ? (value) => onReconstitutionChanged(value ?? false) : null,
            ),
          ],
        );
      case MedicationType.drops:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [volumeField],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static Widget buildSaveButton({required BuildContext context, required VoidCallback onSave}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Save Medication'),
            content: Text('Confirm saving this medication?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () {
                  onSave();
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
      child: Text('Save'),
    );
  }

  static Widget buildCancelOrPreviousButton({
    required BuildContext context,
    required int currentStep,
    required VoidCallback onPressed,
  }) {
    return TextButton(onPressed: onPressed, child: Text(currentStep == 1 ? 'Cancel' : 'Previous'));
  }

  static Widget _buildIconButton(IconData icon, VoidCallback? onPressed, {Color? color}) {
    return Padding(
      padding: FormStyles.buttonPadding,
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? Colors.black54),
        onPressed: onPressed,
      ),
    );
  }
}