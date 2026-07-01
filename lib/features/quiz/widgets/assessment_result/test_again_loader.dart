part of '../../presentation/assessment_result_screen.dart';

class _TestAgainLoader extends StatelessWidget {
  const _TestAgainLoader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return QuizWaveLoader(
      scale: scale,
      message: context.getText(AppKeys.generatingNewQuiz),
      letterStyle: GoogleFonts.andika(
        color: _resultTeal,
        fontSize: 40 * scale,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: 3 * scale,
      ),
      messageStyle: GoogleFonts.andika(
        color: _resultMuted,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w800,
        height: 1.35,
        letterSpacing: 0,
      ),
      messageHorizontalPadding: 0,
    );
  }
}
