import 'package:flutter/material.dart';
import 'medication_form_card.dart';
import '../constants/medication_form_constants.dart';

class MedicationFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const MedicationFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationFormCard(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: MedicationFormConstants.textFieldDecoration(label, helperText),
              keyboardType: keyboardType,
              validator: validator,
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}