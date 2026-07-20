import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class StudentAchievementsHeader extends StatelessWidget {
  const StudentAchievementsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                context.getText(AppKeys.yourAchievement),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: homeDeepInk,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFA03A0F).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            context.getText(AppKeys.viewAllUpper),
            style: const TextStyle(
              color: homeTeal,
              fontSize: FontSize.xxxs,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
