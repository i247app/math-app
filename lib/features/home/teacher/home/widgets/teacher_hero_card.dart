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
      padding: const EdgeInsets.fromLTRB(14, 12, 112, 18),
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
            right: -112,
            bottom: -27,
            child: Opacity(
              opacity: 0.90,
              child: Image.asset(
                'assets/images/numi-mascot.png',
                width: 118,
                height: 118,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              Text(
                context.getText(AppKeys.teacherHeroTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
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
