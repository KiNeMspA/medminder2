import 'package:flutter/material.dart';
import '../../../common/form_styles.dart';
import '../../../common/medication_matrix.dart';
import '../constants/medication_form_constants.dart';
import 'medication_form_field.dart';
import 'medication_form_card.dart';
import 'type_specific_fields/tablet_fields.dart';
import 'type_specific_fields/injection_fields.dart';
import 'type_specific_fields/drops_fields.dart';

class MedicationFormWidgets {
  static Widget buildTypeDropdown({
    required BuildContext context,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return MedicationFormCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72.0),
        child: DropdownButtonFormField<String>(
          decoration: MedicationFormConstants.dropdownDecoration.copyWith(
            labelText: null,
            hint: const Text('Select Medication Type'),
            helperText: 'Choose Medication Type',
            helperMaxLines: 2,
          ),
          value: value,
          items: MedicationFormConstants.medicationTypes
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          style: Theme.of(context).textTheme.bodyLarge,
          borderRadius: BorderRadius.circular(12),
          validator: (value) => value == null ? MedicationFormConstants.typeRequiredMessage : null,
        ),
      ),
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
        helperText: 'Enter the name of the Medication',
        helperMaxLines: 2,
        validator: (value) => value!.isEmpty ? MedicationFormConstants.nameRequiredMessage : null,
        maxWidth: maxWidth,
      ),
    );
  }

  static Widget buildConcentrationField({
    required BuildContext context,
    required TextEditingController controller,
    required String selectedForm,
    required MedicationType selectedType,
    required String unit,
    required ValueChanged<String?> onUnitChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required double maxWidth,
  }) {
    return MedicationFormCard(
      child: MedicationFormField(
        controller: controller,
        label: MedicationFormConstants.concentrationLabel,
        helperText: 'Enter the concentration of the medication per $selectedForm',
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
                items: MedicationMatrix.getConcentrationUnits(selectedType)
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onUnitChanged,
              ),
            ),
            Padding(
              padding: FormStyles.buttonPadding,
              child: IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: onDecrement,
              ),
            ),
            Padding(
              padding: FormStyles.buttonPadding,
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: onIncrement,
              ),
            ),
          ],
        ),
        maxWidth: maxWidth,
      ),
    );
  }

  static Widget buildQuantityField({
    required BuildContext context,
    required TextEditingController controller,
    required String selectedForm,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required double maxWidth,
  }) {
    return MedicationFormCard(
      child: MedicationFormField(
        controller: controller,
        label: MedicationFormConstants.quantityLabel,
        helperText: 'Enter the amount of $selectedForm/s',
        helperMaxLines: 2,
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
              child: Text(
                MedicationFormConstants.unitsLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: FormStyles.buttonPadding,
              child: IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: onDecrement,
              ),
            ),
            Padding(
              padding: FormStyles.buttonPadding,
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: onIncrement,
              ),
            ),
          ],
        ),
        maxWidth: maxWidth,
      ),
    );
  }

  static Widget buildTypeSpecificFields({
    required BuildContext context,
    required MedicationType type,
    required TextEditingController concentrationController,
    required TextEditingController quantityController,
    required TextEditingController unitController,
    required TextEditingController powderAmountController,
    required TextEditingController solventVolumeController,
    required TextEditingController volumeController,
    required TextEditingController totalLiquidController,
    required bool requiresReconstitution,
    required ValueChanged<bool> onReconstitutionChanged,
    required ValueChanged<String?> onUnitChanged,
    required double maxWidth,
  }) {
    switch (type) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return TabletFields(
          concentrationController: concentrationController,
          quantityController: quantityController,
          unitController: unitController,
          selectedType: type,
          onUnitChanged: onUnitChanged,
          maxWidth: maxWidth,
        );
      case MedicationType.injection:
        return InjectionFields(
          concentrationController: concentrationController,
          unitController: unitController,
          powderAmountController: powderAmountController,
          solventVolumeController: solventVolumeController,
          totalLiquidController: totalLiquidController,
          requiresReconstitution: requiresReconstitution,
          onReconstitutionChanged: onReconstitutionChanged,
          onUnitChanged: onUnitChanged,
          maxWidth: maxWidth,
        );
      case MedicationType.drops:
        return DropsFields(
          concentrationController: concentrationController,
          volumeController: volumeController,
          unitController: unitController,
          onUnitChanged: onUnitChanged,
          maxWidth: maxWidth,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}