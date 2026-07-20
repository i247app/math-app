import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class StudentAchievementCard extends StatelessWidget {
  const StudentAchievementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: homeTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: homeTeal,
              size: 28,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    context.getText(AppKeys.progressAchievementTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: homeDeepInk,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.todayCompletedExercises),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grayText,
                      fontSize: FontSize.caption,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFDBEDDC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: homeTeal,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
