part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkLabeledInput extends StatelessWidget {
  const _CreateHomeworkLabeledInput({
    required this.labelKey,
    required this.controller,
  });

  final String labelKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CreateHomeworkLabel(context.getText(labelKey)),
        const SizedBox(height: 8),
        _CreateHomeworkInput(
          controller: controller,
          hintKey: labelKey,
          height: 51,
        ),
      ],
    );
  }
}
