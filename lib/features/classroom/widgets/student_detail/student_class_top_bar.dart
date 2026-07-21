import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentClassTopBar extends StatelessWidget {
  const StudentClassTopBar({
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.brandStrong,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
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
                      'assets/images/student_join_back.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
