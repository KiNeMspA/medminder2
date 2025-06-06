import 'package:flutter/material.dart';
import '../constants/schedule_form_constants.dart';
import 'schedule_form_card.dart';

class ScheduleFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final String? Function(String?)? validator;

  const ScheduleFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ScheduleFormCard(
      child: TextFormField(
        controller: controller,
        decoration: ScheduleFormConstants.textFieldDecoration(label, helperText),
        validator: validator,
      ),
    );
  }
}