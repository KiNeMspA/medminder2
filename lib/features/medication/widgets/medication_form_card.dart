// lib/features/medication/widgets/medication_form_card.dart
import 'package:flutter/material.dart';
import '../constants/medication_form_constants.dart';

class MedicationFormCard extends StatelessWidget {
  final Widget child;

  const MedicationFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ensure full width
      child: Card(
        elevation: MedicationFormConstants.cardElevation,
        shape: MedicationFormConstants.cardShape,
        margin: EdgeInsets.zero, // No margins
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}