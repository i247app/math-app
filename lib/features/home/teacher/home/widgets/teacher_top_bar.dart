import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';

class TeacherTopBar extends StatelessWidget {
  const TeacherTopBar({
    super.key,
    required this.profile,
    required this.topPadding,
    required this.scale,
  });

  final StudentProfile? profile;
  final double topPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final name = displayTeacherName(profile);
    final colors = context.themeColors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topPadding + 16 * scale,
        18 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(color: colors.pageBackgroundTop),
      child: Row(
        children: [
          TeacherAvatar(profile: profile, size: 48 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.teacherWelcomeBack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textSecondary,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.25,
                  ),
                ),
                Text(
                  '$name 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: colors.brandStrong,
              size: 22 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
