import 'package:flutter/material.dart';
import '../../../common/form_styles.dart';

class MedicationFormCard extends StatelessWidget {
  final Widget child;

  const MedicationFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero, // Remove margins for full width
      child: Container(
        width: FormStyles.fullWidthField, // Use full-width constant
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}