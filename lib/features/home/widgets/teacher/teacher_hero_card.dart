import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class TeacherHeroCard extends StatelessWidget {
  const TeacherHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(14, 12, 84, 18),
      decoration: BoxDecoration(
        color: AppColors.teal400,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          const BoxShadow(
            color: Color(0x1A002B6A),
            blurRadius: 20,
            spreadRadius: -4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -84,
            bottom: -18,
            child: Opacity(
              opacity: 0.90,
              child: Image.asset(
                key: const ValueKey('teacher-hero-mascot'),
                'assets/images/numi-mascot.png',
                width: 92,
                height: 92,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  context.getText(AppKeys.teacherHeroTitle),
                  maxLines: 1,
                  style: GoogleFonts.andika(
                    color: Colors.white,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              Text(
                context.getText(AppKeys.teacherHeroSubtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.small,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
