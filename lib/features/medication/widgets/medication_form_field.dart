// lib/features/medication/widgets/medication_form_field.dart
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
  final double? maxWidth;

  const MedicationFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationFormCard(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: MedicationFormConstants.textFieldDecoration(label, helperText).copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), // Increase vertical padding
                ),
                keyboardType: keyboardType,
                validator: validator,
              ),
            ),
            if (suffix != null) suffix!,
          ],
        ),
      ),
    );
  }
}