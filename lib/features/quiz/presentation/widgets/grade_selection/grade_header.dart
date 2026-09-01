import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class GradeHeader extends StatelessWidget {
  const GradeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return PageHeader(
      title: context.getText(AppKeys.chooseGrade),
      backgroundColor: colors.pageBackground,
      actionWidth: 52,
      horizontalPadding: 12,
      titleFontSize: 24,
      leading: AppBackButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        size: 44,
        iconSize: 18,
      ),
    );
  }
}
