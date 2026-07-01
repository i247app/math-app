part of '../../presentation/assessment_result_screen.dart';

class _ReviewText extends StatelessWidget {
  const _ReviewText({required this.scale, required this.reviewText});

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final text = '"$reviewText"';
    final highlight = context.getText(AppKeys.defaultAiReviewHighlight);
    final highlightIndex = text.toLowerCase().indexOf(highlight);
    final bodyStyle = GoogleFonts.andika(
      color: _resultMuted,
      fontSize: 12 * scale,
      fontWeight: FontWeight.w400,
      height: 19.5 / 12,
      letterSpacing: -0.1 * scale,
    );

    if (highlightIndex == -1) {
      return Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: bodyStyle,
      );
    }

    return RichText(
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: text.substring(0, highlightIndex)),
          TextSpan(
            text: text.substring(
              highlightIndex,
              highlightIndex + highlight.length,
            ),
            style: bodyStyle.copyWith(
              color: _resultTeal,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(highlightIndex + highlight.length)),
        ],
      ),
    );
  }
}
