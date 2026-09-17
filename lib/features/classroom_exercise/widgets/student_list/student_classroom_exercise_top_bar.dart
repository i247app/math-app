import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentClassroomExerciseTopBar extends StatelessWidget {
  const StudentClassroomExerciseTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/student-join-back.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 80),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: colors.brandStrong,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  height: 34 / 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
