import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
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
    return PlacementResultTitle(label: label, compact: compact);
  }
}

class PlacementResultTitle extends StatelessWidget {
  const PlacementResultTitle({
    super.key,
    required this.label,
    required this.compact,
    this.containerKey = const ValueKey('placement-grade-container'),
    this.labelKey = const ValueKey('placement-grade'),
    this.fontSize,
    this.arcHeight = 5,
    this.arcAngle = 0.22,
    this.textColor,
  });

  final String label;
  final bool compact;
  final Key containerKey;
  final Key labelKey;
  final double? fontSize;
  final double arcHeight;
  final double arcAngle;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final separatorIndex = label.lastIndexOf(' ');
    final splitIndex = label.contains('/')
        ? label.indexOf('/')
        : separatorIndex < 0
        ? (label.characters.length / 2).ceil()
        : label.characters.toList().indexOf(' ');
    final glyphs = label.characters.toList();
    double glyphProgress(int index) =>
        glyphs.length <= 1 ? 0.5 : index / (glyphs.length - 1);
    final textStyle = GoogleFonts.nunito(
      fontSize: fontSize ?? (compact ? 34 : 38),
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: 0.5,
    );

    return SizedBox(
      key: containerKey,
      height: fontSize == null
          ? (compact ? 44 : 48)
          : fontSize! + arcHeight * 2,
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
                child: Opacity(opacity: 0, child: Text(label, key: labelKey)),
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
                          -arcHeight * math.sin(glyphProgress(index) * math.pi),
                        ),
                        child: Transform.rotate(
                          angle: (glyphProgress(index) - 0.5) * arcAngle,
                          child: Text(
                            glyphs[index],
                            style: textStyle.copyWith(
                              color:
                                  textColor ??
                                  (index < splitIndex
                                      ? (isDark
                                            ? colors.brandStrong
                                            : AppColors.teal600)
                                      : (isDark
                                            ? colors.accent
                                            : AppColors.coral600)),
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
