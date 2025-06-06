// lib/features/medication/widgets/medication_form_field.dart
import 'package:flutter/material.dart';
import 'medication_form_card.dart';
import '../constants/medication_form_constants.dart';

class MedicationFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final int? helperMaxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final double? maxWidth;

  const MedicationFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.helperMaxLines,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: MedicationFormConstants.textFieldDecoration(label, null).copyWith(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    keyboardType: keyboardType,
                    validator: validator,
                  ),
                ),
                if (suffix != null) suffix!,
              ],
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Text(
                helperText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                maxLines: helperMaxLines ?? 2,
                overflow: TextOverflow.visible,
              ),
            ),
        ],
      ),
    );
  }
}