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
        foregroundColor: colors.brand,
        backgroundColor: colors.brand.withValues(alpha: 0.12),
        minimumSize: const Size(48, 48),
      ),
      icon: const Icon(Icons.volume_up_rounded, size: 28),
    );
  }
}
