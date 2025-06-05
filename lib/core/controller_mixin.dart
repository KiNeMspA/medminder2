// lib/core/controller_mixin.dart
import 'package:flutter/material.dart';

mixin ControllerMixin<T extends StatefulWidget> on State<T> {
  void setupListeners(List<TextEditingController> controllers, VoidCallback listener) {
    for (var controller in controllers) {
      controller.addListener(listener);
    }
  }

  void disposeControllers(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller
        ..removeListener(() {})
        ..dispose();
    }
  }
}