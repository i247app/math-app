import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/assessment_result_style.dart';

class AssessmentAiReviewText extends StatelessWidget {
  const AssessmentAiReviewText({
    super.key,
    required this.scale,
    required this.reviewText,
  });

  final double scale;
  final String reviewText;

  @override
  Widget build(BuildContext context) {
    final text = '"$reviewText"';
    final highlight = context.getText(AppKeys.defaultAiReviewHighlight);
    final highlightIndex = text.toLowerCase().indexOf(highlight);
    final bodyStyle = GoogleFonts.andika(
      color: AssessmentResultStyle.muted,
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
              color: AssessmentResultStyle.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(highlightIndex + highlight.length)),
        ],
      ),
    );
  }
}
