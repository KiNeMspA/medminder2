import 'package:flutter/material.dart';
import '../../medication/utils/medication_form_utils.dart';
import '../constants/medication_form_constants.dart';

class SplitInputField extends StatefulWidget {
  final String labelText;
  final String infoText;
  final TextEditingController controller;
  final String? unit;
  final List<String>? unitOptions;
  final ValueChanged<String?>? onUnitChanged;
  final TextInputType keyboardType;
  final bool isInteger;
  final String? Function(String?)? validator;
  final double maxWidth;

  const SplitInputField({
    super.key,
    required this.labelText,
    required this.infoText,
    required this.controller,
    this.unit,
    this.unitOptions,
    this.onUnitChanged,
    required this.keyboardType,
    this.isInteger = false,
    this.validator,
    required this.maxWidth,
  });

  @override
  _SplitInputFieldState createState() => _SplitInputFieldState();
}

class _SplitInputFieldState extends State<SplitInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.infoText,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 72, // Increased to accommodate padding
          width: widget.maxWidth,
          decoration: BoxDecoration(
            border: Border.all(color: _isFocused ? Theme.of(context).colorScheme.primary : Colors.grey),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center, // Center text vertically
                  style: const TextStyle(fontSize: 14),
                  onTap: () {
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 28), // Balanced for centering and caret
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    alignLabelWithHint: false,
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!_focusNode.hasFocus) _focusNode.requestFocus();
                            MedicationFormUtils().incrementField(widget.controller, isInteger: widget.isInteger);
                            widget.controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: widget.controller.text.length),
                            );
                          },
                          child: Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            if (!_focusNode.hasFocus) _focusNode.requestFocus();
                            MedicationFormUtils().decrementField(widget.controller, isInteger: widget.isInteger);
                            widget.controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: widget.controller.text.length),
                            );
                          },
                          child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.primary, size: 16),
                        ),
                      ],
                    ),
                  ),
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey, // Ensure divider is visible
              ),
              Expanded(
                flex: 1,
                child: widget.unitOptions != null && widget.unitOptions!.isNotEmpty
                    ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.unit,
                    isExpanded: true,
                    items: widget.unitOptions!
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          unit,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: widget.onUnitChanged,
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                    dropdownColor: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    icon: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                )
                    : Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    widget.unit ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}