import 'package:flutter/material.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/exam/models/exam_answer_selection.dart';

class ExamNumericInput extends StatefulWidget {
  const ExamNumericInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<ExamNumericInput> createState() => _ExamNumericInputState();
}

class _ExamNumericInputState extends State<ExamNumericInput> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(ExamNumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalid =
        widget.value.trim().isNotEmpty &&
        ExamAnswerSelection.parseNumber(widget.value) == null;
    return TextField(
      key: const ValueKey('exam-numeric-input'),
      controller: _controller,
      // A text keyboard keeps the slash available for fractions on mobile.
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: context.getText(AppKeys.examNumericAnswer),
        hintText: context.getText(AppKeys.examNumericHint),
        errorText: invalid ? context.getText(AppKeys.examNumericInvalid) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
