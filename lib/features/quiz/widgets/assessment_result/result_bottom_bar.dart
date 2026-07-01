part of '../../presentation/assessment_result_screen.dart';

class _ResultBottomBar extends StatelessWidget {
  const _ResultBottomBar({
    required this.scale,
    required this.onTest,
    required this.onPractice,
  });

  final double scale;
  final VoidCallback onTest;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ResultActionButton(
          label: context.getText(AppKeys.assessmentUpper),
          background: _resultCoral,
          scale: scale,
          onTap: onTest,
        ),
        SizedBox(width: 40 * scale),
        _ResultActionButton(
          label: context.getText(AppKeys.practiceUpper),
          icon: Icons.arrow_forward_rounded,
          background: _resultHeaderTeal,
          scale: scale,
          onTap: onPractice,
        ),
      ],
    );
  }
}
