import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/presentation/widgets/shared/quiz_header_icon_button.dart';

class AssessmentHeader extends StatelessWidget {
  const AssessmentHeader({super.key, required this.onClose});

  final VoidCallback onClose;

  static const double height = 60;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: colors.surface,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: QuizHeaderIconButton(
              icon: Icons.close_rounded,
              color: colors.brandStrong,
              circle: true,
              onTap: onClose,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              context.getText(AppKeys.assessmentHeaderTitle),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.brandStrong,
                fontSize: FontSize.xl,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: QuizHeaderIconButton(
              icon: Icons.help_outline_rounded,
              color: colors.brandStrong,
              circle: true,
              onTap: HapticFeedback.selectionClick,
            ),
          ),
        ],
      ),
    );
  }
}
