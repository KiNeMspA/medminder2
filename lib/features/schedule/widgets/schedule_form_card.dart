import 'package:flutter/material.dart';
import '../constants/schedule_form_constants.dart';

class ScheduleFormCard extends StatelessWidget {
  final Widget child;

  const ScheduleFormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ScheduleFormConstants.cardElevation,
      shape: ScheduleFormConstants.cardShape,
      child: Padding(
        padding: ScheduleFormConstants.cardPadding,
        child: child,
      ),
    );
  }
}