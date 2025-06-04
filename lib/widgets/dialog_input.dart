import 'package:flutter/material.dart';

class DialogInput extends StatelessWidget {
  final String title;
  final String hint;
  final String helpText;
  final TextEditingController controller;
  final VoidCallback onConfirm;

  const DialogInput({
    super.key,
    required this.title,
    required this.hint,
    required this.helpText,
    required this.controller,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(helpText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: onConfirm, child: const Text('Confirm')),
      ],
    );
  }
}