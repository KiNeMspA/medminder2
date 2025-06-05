// lib/widgets/form_widgets.dart
import 'package:flutter/material.dart';

class FormWidgets {
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required String label,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<String>? dropdownItems,
    String? dropdownValue,
    ValueChanged<String?>? onDropdownChanged,
  }) async {
    final controller = TextEditingController(text: initialValue);
    String? dropdownCurrentValue = dropdownValue;
    String? errorText;

    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.all(24),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 280,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (dropdownItems != null && dropdownItems.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: label,
                            helperText: helperText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          value: dropdownCurrentValue,
                          items: dropdownItems
                              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              dropdownCurrentValue = value;
                              onDropdownChanged?.call(value);
                            });
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: label,
                          helperText: helperText,
                          helperMaxLines: 1,
                          errorText: errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        keyboardType: keyboardType,
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        onChanged: (value) {
                          setState(() {
                            errorText = validator?.call(value);
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (dropdownItems != null) {
                              if (dropdownCurrentValue != null) {
                                Navigator.pop(context, dropdownCurrentValue);
                              } else {
                                setState(() {
                                  errorText = 'Please select an option';
                                });
                              }
                            } else {
                              final textError = validator?.call(controller.text);
                              setState(() {
                                errorText = textError;
                              });
                              if (textError == null) {
                                Navigator.pop(context, controller.text);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}