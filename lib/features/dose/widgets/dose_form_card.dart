import 'package:flutter/material.dart';
import '../constants/dose_form_constants.dart';

class DoseFormCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const DoseFormCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: DoseFormConstants.cardElevation,
      shape: DoseFormConstants.cardShape,
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.edit, color: Colors.grey),
        contentPadding: DoseFormConstants.cardContentPadding,
        onTap: onTap,
      ),
    );
  }
}