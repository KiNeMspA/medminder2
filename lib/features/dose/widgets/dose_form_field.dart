import 'package:flutter/material.dart';
import '../../../../../widgets/form_widgets.dart';

class DoseFormField {
  static Future<void> showEditDialog({
    required BuildContext context,
    required String title,
    required String label,
    required TextEditingController controller,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<String>? dropdownItems,
    String? dropdownValue,
    ValueChanged<String?>? onDropdownChanged,
    VoidCallback? onChanged,
  }) async {
    final result = await FormWidgets.showInputDialog(
      context: context,
      title: title,
      initialValue: controller.text,
      label: label,
      helperText: helperText,
      keyboardType: keyboardType,
      validator: validator,
      dropdownItems: dropdownItems,
      dropdownValue: dropdownValue,
      onDropdownChanged: onDropdownChanged,
    );
    if (result != null) {
      controller.text = result;
      onChanged?.call();
    }
  }
}