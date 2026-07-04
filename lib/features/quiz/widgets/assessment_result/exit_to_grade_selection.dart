import 'package:flutter/material.dart';

void exitToGradeSelection(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  }
  if (navigator.canPop()) {
    navigator.pop();
  }
}
