import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

class StudentHomeworkScoreRing extends StatelessWidget {
  const StudentHomeworkScoreRing({super.key, required this.scoreText});
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    final scoreTotal = slashIndex == -1
        ? '/10'
        : scoreText.substring(slashIndex);

    return Center(
      child: SizedBox(
        width: 192,
        height: 168,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192,
                height: 160,
                decoration: BoxDecoration(
                  color: colors.infoSurface.withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.infoSurface.withValues(alpha: 0.70),
                      blurRadius: 32,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.elevatedSurface,
                border: Border.all(color: colors.brandStrong, width: 9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 3,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: context.textStyles.displayLarge?.copyWith(
                            color: colors.success,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: context.textStyles.displayLarge?.copyWith(
                            color: colors.textPrimary,
                            fontSize: FontSize.displayLarge,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
