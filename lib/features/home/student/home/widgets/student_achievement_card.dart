import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/home/widgets/home_visual_constants.dart';

class StudentAchievementCard extends StatelessWidget {
  const StudentAchievementCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104 * scale,
      padding: EdgeInsets.all(21 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64 * scale,
            height: 64 * scale,
            decoration: BoxDecoration(
              color: homeTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28 * scale),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: homeTeal,
              size: 28 * scale,
            ),
          ),
          SizedBox(width: 20 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(AppKeys.progressAchievementTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: homeDeepInk,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  context.getText(AppKeys.todayCompletedExercises),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEDDC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: homeTeal,
              size: 24 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
