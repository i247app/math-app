import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/features/classroom/widgets/student_tab/student_classroom_skeleton_block.dart';

class StudentHomeSectionsLoading extends StatefulWidget {
  const StudentHomeSectionsLoading({super.key});

  @override
  State<StudentHomeSectionsLoading> createState() =>
      _StudentHomeSectionsLoadingState();
}

class _StudentHomeSectionsLoadingState extends State<StudentHomeSectionsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return AppSkeletonShimmer(
      controller: _controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 116,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: colors.elevatedSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentClassroomSkeletonBlock(
                  width: 150,
                  height: 15,
                  radius: 7,
                ),
                SizedBox(height: 12),
                StudentClassroomSkeletonBlock(height: 56, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              for (var index = 0; index < 2; index++) ...[
                const Expanded(
                  child: StudentClassroomSkeletonBlock(height: 138, radius: 18),
                ),
                if (index == 0) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const StudentClassroomSkeletonBlock(
            width: 170,
            height: 18,
            radius: 8,
          ),
          const SizedBox(height: 10),
          const StudentClassroomSkeletonBlock(height: 104, radius: 18),
        ],
      ),
    );
  }
}
