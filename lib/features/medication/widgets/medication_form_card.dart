import 'package:flutter/material.dart';
import '../constants/medication_form_constants.dart';

class MedicationFormCard extends StatelessWidget {
  final Widget child;

  const MedicationFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: MedicationFormConstants.cardElevation,
      shape: MedicationFormConstants.cardShape,
      child: Padding(
        padding: MedicationFormConstants.cardPadding,
        child: child,
      ),
    );
  }
}