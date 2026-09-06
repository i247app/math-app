import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentJoinAnotherClassroomTitle extends StatelessWidget {
  const StudentJoinAnotherClassroomTitle({
    super.key,
    required this.hasJoinedClassrooms,
  });

  final bool hasJoinedClassrooms;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.tealLightSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.brandTeal,
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              context.getText(
                hasJoinedClassrooms
                    ? AppKeys.studentJoinAnotherClassroom
                    : AppKeys.studentJoinClassroom,
              ),
              style: const TextStyle(
                color: AppColors.textTeal,
                fontSize: FontSize.large,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
