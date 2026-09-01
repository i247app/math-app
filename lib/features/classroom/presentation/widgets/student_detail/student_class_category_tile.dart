import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/features/classroom/presentation/helpers/student_class_detail_helpers.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class StudentClassCategoryTile extends StatelessWidget {
  const StudentClassCategoryTile({
    super.key,
    required this.backgroundColor,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color backgroundColor;
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ?? () => showStudentClassComingSoon(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 20),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withValues(alpha: 0.50)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(iconAsset, width: 18, height: 18),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w400,
                    height: 20 / 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.xxs,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
