import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/constants/home_visual_constants.dart';

class StudentAchievementsHeader extends StatelessWidget {
  const StudentAchievementsHeader({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.getText(AppKeys.yourAchievement),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: homeDeepInk,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 10 * scale),
              Container(
                width: 48 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFA03A0F).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 3 * scale),
          child: Text(
            context.getText(AppKeys.viewAllUpper),
            style: TextStyle(
              color: homeTeal,
              fontSize: FontSize.caption * 0.85 * scale,
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
