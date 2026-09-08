import 'package:flutter/material.dart';

import 'package:numi/features/home/widgets/teacher/teacher_assignments_loading_panel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_hero_skeleton.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_section_header_skeleton.dart';
import 'package:numi/features/home/widgets/teacher/teacher_loading_panel.dart';
import 'package:numi/features/home/widgets/teacher/teacher_top_bar.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

/// Shared by profile resolution and the first teacher Home data load.
class TeacherHomeSkeleton extends StatelessWidget {
  const TeacherHomeSkeleton({
    super.key,
    required this.profile,
    required this.bottomPadding,
    required this.onNotificationTap,
    this.hasUnreadNotifications = false,
  });

  final StudentProfile? profile;
  final double bottomPadding;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeacherTopBar(
            profile: profile,
            topPadding: MediaQuery.paddingOf(context).top,
            onNotificationTap: onNotificationTap,
            hasUnreadNotifications: hasUnreadNotifications,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: teacherTabContentHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 22),
                TeacherHomeHeroSkeleton(),
                SizedBox(height: 28),
                TeacherAppSectionHeaderSkeleton(),
                SizedBox(height: 12),
                TeacherLoadingPanel(),
                SizedBox(height: 30),
                TeacherAppSectionHeaderSkeleton(),
                SizedBox(height: 12),
                TeacherAssignmentsLoadingPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
