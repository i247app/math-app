import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class CreateHomeworkPublishSwitch extends StatelessWidget {
  const CreateHomeworkPublishSwitch({
    super.key,
    required this.isPublished,
    required this.onChanged,
  });

  final bool isPublished;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.getText(AppKeys.teacherAssignmentPublishLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: AppColors.textInkDark,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
              height: 18 / 14,
            ),
          ),
        ),
        Text(
          context.getText(
            isPublished
                ? AppKeys.teacherAssignmentVisibilityPublic
                : AppKeys.teacherAssignmentVisibilityPrivate,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: AppColors.textInkDark.withValues(alpha: 0.65),
            fontSize: FontSize.xxs,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Switch.adaptive(
            value: isPublished,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.teal520,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFC4C6D2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
