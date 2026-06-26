part of '../../../home_screen.dart';

class _StudentHomeworkPanel extends StatelessWidget {
  const _StudentHomeworkPanel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _StudentEmptyPanel(
      scale: scale,
      icon: Icons.assignment_rounded,
      title: context.getText(AppKeys.studentNoHomeworkTitle),
      message: context.getText(AppKeys.studentNoHomeworkMessage),
    );
  }
}
