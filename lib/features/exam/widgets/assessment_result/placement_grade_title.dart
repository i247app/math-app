import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';

class PlacementGradeTitle extends StatelessWidget {
  const PlacementGradeTitle({
    super.key,
    required this.grade,
    required this.compact,
  });

  final int grade;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = grade == AssessmentFlowPolicy.minimumGrade
        ? context.getText(AppKeys.placementResultKindergarten)
        : context.formatText(AppKeys.placementResultGrade, {'grade': grade});
    final separatorIndex = label.lastIndexOf(' ');
    final splitIndex = separatorIndex < 0
        ? (label.characters.length / 2).ceil()
        : label.characters.toList().indexOf(' ');
    final glyphs = label.characters.toList();
    final textStyle = GoogleFonts.nunito(
      fontSize: compact ? 34 : 38,
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: 0.5,
    );

    return SizedBox(
      key: const ValueKey('placement-grade-container'),
      height: compact ? 44 : 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Semantics(
          label: label,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Keeps the complete localized title available to finders and
              // accessibility tools while the visible glyphs follow an arc.
              ExcludeSemantics(
                child: Opacity(
                  opacity: 0,
                  child: Text(label, key: const ValueKey('placement-grade')),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var index = 0; index < glyphs.length; index++)
                      Transform.translate(
                        offset: Offset(
                          0,
                          -5.0 *
                              (1 -
                                  ((index / (glyphs.length - 1)) * 2 - 1)
                                      .abs()),
                        ),
                        child: Transform.rotate(
                          angle: ((index / (glyphs.length - 1)) - 0.5) * 0.22,
                          child: Text(
                            glyphs[index],
                            style: textStyle.copyWith(
                              color: index < splitIndex
                                  ? AppColors.teal600
                                  : AppColors.coral600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
