import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherStudyLoadMoreButton extends StatelessWidget {
  const TeacherStudyLoadMoreButton({
    super.key,
    required this.loadCount,
    required this.onTap,
  });

  final int loadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal520,
          minimumSize: const Size(176, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          side: const BorderSide(color: AppColors.teal520),
          shape: const StadiumBorder(),
        ),
        icon: const Icon(Icons.expand_more_rounded, size: 21),
        label: Text(
          context.formatText(AppKeys.teacherStudyShowMore, {
            'count': loadCount,
          }),
          style: GoogleFonts.andika(
            fontSize: FontSize.small,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
