import 'package:material_ui/material_ui.dart';

void exitToGradeSelection(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  }
}
