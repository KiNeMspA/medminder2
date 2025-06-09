import 'package:flutter/material.dart';
import '../../../common/form_styles.dart';
import '../../../common/utils/formatters.dart';
import 'medication_form_card.dart';

class MedicationFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helperText;
  final int? helperMaxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final double maxWidth;

  const MedicationFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    this.helperMaxLines,
    this.validator,
    this.keyboardType,
    this.suffix,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: suffix,
                  ),
                  keyboardType: keyboardType,
                  validator: validator,
                  inputFormatters: keyboardType == const TextInputType.numberWithOptions(decimal: true)
                      ? [DecimalTextInputFormatter()]
                      : null,
                ),
              ),
            ),
          ],
        ),
        if (helperText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: helperMaxLines ?? 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}