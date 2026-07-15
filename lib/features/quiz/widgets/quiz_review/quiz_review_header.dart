import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';

class QuizReviewHeader extends StatelessWidget {
  const QuizReviewHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return PageHeader(
      title: context.getText(AppKeys.quizDetailTitle),
      scale: 1,
      topInset: 0,
      actionWidth: 52,
      horizontalPadding: 12,
      titleFontSize: 24,
      leading: IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onBack();
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: colors.brandStrong,
          size: 28,
        ),
        tooltip: context.getText(AppKeys.back),
      ),
    );
  }
}
