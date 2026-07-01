part of '../../presentation/assessment_screen.dart';

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.scale, required this.question});

  final double scale;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 356 * scale,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 26 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: const Color(0xFFDCCACA)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _assessmentInk,
            fontSize: 72 * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
