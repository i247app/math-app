import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/language/language_back_button.dart';
import 'package:numi/features/settings/widgets/language/language_header_curve_painter.dart';

class LanguageHeader extends StatelessWidget {
  const LanguageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return SizedBox(
      height: 70,
      child: CustomPaint(
        painter: LanguageHeaderCurvePainter(
          backgroundColor: colors.pageBackground,
          lineColor: colors.accentStrong,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              const LanguageBackButton(),
              Expanded(
                child: Text(
                  context.getText(AppKeys.languageTitle),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}
