import 'package:flutter/widgets.dart';

/// Coordinates fixed-length numeric input fields, including paste, focus
/// progression, and backspace behavior.
class NumericCodeInputController {
  NumericCodeInputController({this.length = 4})
    : assert(length > 0),
      controllers = List.generate(length, (_) => TextEditingController()),
      focusNodes = List.generate(length, (_) => FocusNode());

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  String get value => controllers.map((controller) => controller.text).join();

  bool get isComplete =>
      controllers.every((controller) => controller.text.isNotEmpty);

  void updateDigit(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      controllers[index].clear();
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
      return;
    }

    var nextIndex = index;
    for (final digit in digits.split('')) {
      if (nextIndex >= length) {
        break;
      }
      controllers[nextIndex].text = digit;
      controllers[nextIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      nextIndex++;
    }

    if (nextIndex < length) {
      focusNodes[nextIndex].requestFocus();
    } else {
      focusNodes.last.unfocus();
    }
  }

  void clearPreviousAndFocus(int index) {
    if (index == 0) {
      return;
    }
    controllers[index - 1].clear();
    focusNodes[index - 1].requestFocus();
  }

  void clear() {
    for (final controller in controllers) {
      controller.clear();
    }
  }

  void requestFocusFirst() => focusNodes.first.requestFocus();

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
  }
}
