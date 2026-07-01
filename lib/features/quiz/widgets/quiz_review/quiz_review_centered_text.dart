part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewCenteredText extends StatelessWidget {
  const _QuizReviewCenteredText(
    this.text, {
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.verticalOffset = 0,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          strutStyle: StrutStyle(
            fontSize: fontSize,
            height: 1,
            forceStrutHeight: true,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
