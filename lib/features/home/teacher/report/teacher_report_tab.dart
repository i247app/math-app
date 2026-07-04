import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/classroom/widgets/teacher_shared/teacher_style.dart';

class TeacherReportTab extends StatelessWidget {
  const TeacherReportTab({
    super.key,
    required this.bottomPadding,
    required this.scale,
  });

  final double bottomPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        22 * scale,
        MediaQuery.paddingOf(context).top + 28 * scale,
        22 * scale,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.getText(AppKeys.teacherReportTitle),
            style: GoogleFonts.andika(
              color: teacherTeal,
              fontSize: FontSize.xxxl * scale,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          SizedBox(height: 18 * scale),
          Padding(
            padding: EdgeInsets.fromLTRB(4 * scale, 0, 4 * scale, 14 * scale),
            child: Container(
              padding: EdgeInsets.all(22 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24 * scale),
                border: Border.all(color: const Color(0xFFE2E9EC)),
                boxShadow: [
                  BoxShadow(
                    color: teacherBlue.withValues(alpha: 0.06),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 10 * scale),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 92 * scale,
                    height: 92 * scale,
                    decoration: BoxDecoration(
                      color: teacherHero.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: teacherTeal,
                      size: 44 * scale,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    context.getText(AppKeys.teacherReportComingSoon),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: teacherInk,
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    context.getText(AppKeys.teacherReportPlaceholder),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: teacherMuted,
                      fontSize: FontSize.caption * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
