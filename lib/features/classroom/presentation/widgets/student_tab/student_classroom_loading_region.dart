import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/features/classroom/presentation/widgets/student_tab/student_classroom_skeleton_block.dart';

class StudentClassroomLoadingRegion extends StatefulWidget {
  const StudentClassroomLoadingRegion({super.key});

  @override
  State<StudentClassroomLoadingRegion> createState() =>
      _StudentClassroomLoadingRegionState();
}

class _StudentClassroomLoadingRegionState
    extends State<StudentClassroomLoadingRegion>
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
    return ColoredBox(
      color: colors.pageBackground,
      child: AppSkeletonShimmer(
        controller: _controller,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: StudentClassroomSkeletonBlock(
                        height: 118,
                        radius: 22,
                      ),
                    ),
                    Expanded(
                      child: StudentClassroomSkeletonBlock(
                        height: 118,
                        radius: 22,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: StudentClassroomSkeletonBlock(
                    width: 210,
                    height: 30,
                    radius: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: StudentClassroomSkeletonBlock(height: 48, radius: 20),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: _ClassroomSearchSkeleton(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: StudentClassroomSkeletonBlock(
                    width: 170,
                    height: 24,
                    radius: 10,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: StudentClassroomSkeletonBlock(height: 120, radius: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassroomSearchSkeleton extends StatelessWidget {
  const _ClassroomSearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7E8)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentClassroomSkeletonBlock(width: 92, height: 18, radius: 8),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: StudentClassroomSkeletonBlock(height: 43, radius: 8),
          ),
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: StudentClassroomSkeletonBlock(
              width: 45,
              height: 18,
              radius: 8,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: StudentClassroomSkeletonBlock(height: 30, radius: 15),
                ),
                Expanded(
                  child: StudentClassroomSkeletonBlock(height: 30, radius: 15),
                ),
                Expanded(
                  child: StudentClassroomSkeletonBlock(height: 30, radius: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
