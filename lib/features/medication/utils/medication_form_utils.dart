import 'package:flutter/material.dart';
import '../../../common/medication_matrix.dart';
import '../../../common/utils/formatters.dart';
import '../constants/medication_form_constants.dart';

class MedicationFormUtils {
  static Map<String, TextEditingController> createControllers() => {
    'name': TextEditingController(),
    'concentration': TextEditingController(text: '0'),
    'quantity': TextEditingController(text: '0'),
    'volume': TextEditingController(text: '0'),
    'powderAmount': TextEditingController(text: '0'),
    'solventVolume': TextEditingController(text: '0'),
  };

  void setupListeners(Map<String, TextEditingController> controllers, VoidCallback onChanged) {
    controllers.forEach((_, controller) => controller.addListener(onChanged));
  }

  void disposeControllers(Map<String, TextEditingController> controllers) {
    controllers.forEach((_, controller) => controller.dispose());
  }

  void incrementField(TextEditingController controller, {bool isInteger = false}) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    final newValue = isInteger ? currentValue + 1 : currentValue + 1.0;
    controller.text = isInteger ? newValue.toInt().toString() : Utils.removeTrailingZeros(newValue);
  }

  void decrementField(TextEditingController controller, {bool isInteger = false}) {
    final currentValue = double.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      final newValue = isInteger ? currentValue - 1 : currentValue - 1.0;
      controller.text = isInteger ? newValue.toInt().toString() : Utils.removeTrailingZeros(newValue);
    }
  }

  String buildSummary({
    required String name,
    required MedicationType selectedType,
    required String? selectedForm,
    required String? selectedSubType,
    required String concentration,
    required String quantity,
    required String volume,
    required String unit,
  }) {
    if (name.isEmpty || selectedForm == null) return '||||||';
    final conc = double.tryParse(concentration) ?? 0;
    final qty = double.tryParse(quantity) ?? 0;
    final qtyNum = qty;
    final medType = selectedForm;
    final pluralMedType = (medType == 'Tablet' || medType == 'Capsule') && qtyNum > 1 ? '${medType}s' : medType;
    final vol = double.tryParse(volume) ?? 0;
    final totalUnit = unit.isEmpty ? '[Unit]' : unit;
    final total = conc * qty;
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

    switch (selectedType) {
      case MedicationType.tablet:
      case MedicationType.capsule:
        return '$name|$pluralMedType|${Utils.removeTrailingZeros(conc)} $totalUnit per $medQtyUnit|$stockQtyUnit|${Utils.removeTrailingZeros(qty)}|${Utils.removeTrailingZeros(total)}$totalUnit|$totalUnit';
      case MedicationType.injection:
        return '$name|$pluralMedType|${Utils.removeTrailingZeros(conc)} $totalUnit per $medQtyUnit|$stockQtyUnit|${Utils.removeTrailingZeros(vol)}|${Utils.removeTrailingZeros(total)}$totalUnit|$totalUnit';
      case MedicationType.drops:
        return '$name|$pluralMedType|${Utils.removeTrailingZeros(vol)} $totalUnit per $medQtyUnit|$stockQtyUnit|${Utils.removeTrailingZeros(vol)}|${Utils.removeTrailingZeros(total)}$totalUnit|$totalUnit';
      default:
        return '$name|$pluralMedType|${Utils.removeTrailingZeros(conc)} $totalUnit per $medQtyUnit|$stockQtyUnit|${Utils.removeTrailingZeros(qty)}|${Utils.removeTrailingZeros(total)}$totalUnit|$totalUnit';
    }
  }

  Future<Map<String, dynamic>> validateInput({
    required BuildContext context,
    required Map<String, TextEditingController> controllers,
    required MedicationType selectedType,
    required String? selectedSubType,
    required bool requiresReconstitution,
    required Future<bool> Function(String) isNameUnique,
  }) async {
    final result = {'valid': true, 'message': ''};
    final name = controllers['name']!.text.trim();
    final concentration = double.tryParse(controllers['concentration']!.text) ?? 0.0;
    final quantity = double.tryParse(controllers['quantity']!.text) ?? 0.0;
    final volume = double.tryParse(controllers['volume']!.text) ?? 0.0;

    if (name.isEmpty) {
      result['valid'] = false;
      result['message'] = 'Medication name is required';
      return result;
    }
    if (!(await isNameUnique(name))) {
      result['valid'] = false;
      result['message'] = 'Medication name must be unique';
      return result;
    }
    if (concentration <= 0) {
      result['valid'] = false;
      result['message'] = 'Concentration must be greater than 0';
      return result;
    }
    if ((selectedType == MedicationType.tablet || selectedType == MedicationType.capsule) && quantity <= 0) {
      result['valid'] = false;
      result['message'] = 'Quantity must be greater than 0';
      return result;
    }
    if ((selectedType == MedicationType.injection || selectedType == MedicationType.drops) && volume <= 0) {
      result['valid'] = false;
      result['message'] = 'Volume must be greater than 0';
      return result;
    }
    if (requiresReconstitution) {
      final powderAmount = double.tryParse(controllers['powderAmount']!.text) ?? 0.0;
      final solventVolume = double.tryParse(controllers['solventVolume']!.text) ?? 0.0;
      if (powderAmount <= 0 || solventVolume <= 0) {
        result['valid'] = false;
        result['message'] = 'Powder amount and solvent volume must be greater than 0';
        return result;
      }
    }
    return result;
  }

  double getStockQuantity({
    required MedicationType selectedType,
    required String quantity,
    required String volume,
  }) {
    return selectedType == MedicationType.drops || selectedType == MedicationType.injection
        ? double.tryParse(volume) ?? 0
        : double.tryParse(quantity) ?? 0;
  }
}