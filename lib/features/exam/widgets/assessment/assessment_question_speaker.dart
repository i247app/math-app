import 'package:flutter/material.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class AssessmentQuestionSpeaker extends StatelessWidget {
  const AssessmentQuestionSpeaker({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return IconButton.filledTonal(
      key: const ValueKey('read-question'),
      tooltip: AppStrings.current(AppKeys.examReadQuestion),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: colors.onBrand,
        backgroundColor: colors.brand,
        minimumSize: const Size(48, 48),
        shape: const CircleBorder(),
      ),
      icon: const Icon(Icons.play_arrow_rounded, size: 28),
    );
  }
}
