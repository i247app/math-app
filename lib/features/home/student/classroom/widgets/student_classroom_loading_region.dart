import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/student/classroom/widgets/student_classroom_skeleton_block.dart';

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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              final shimmerWidth = bounds.width * 1.2;
              final start = -shimmerWidth;
              final end = bounds.width;
              final dx = start + (end - start) * _controller.value;
              return LinearGradient(
                colors: [
                  colors.surface.withValues(alpha: 0),
                  colors.surface.withValues(alpha: 0.72),
                  colors.surface.withValues(alpha: 0),
                ],
                stops: const [0.28, 0.5, 0.72],
              ).createShader(Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height));
            },
            child: child,
          );
        },
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: const [
            Row(
              children: [
                Expanded(
                  child: StudentClassroomSkeletonBlock(height: 118, radius: 22),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StudentClassroomSkeletonBlock(height: 118, radius: 22),
                ),
              ],
            ),
            SizedBox(height: 30),
            StudentClassroomSkeletonBlock(width: 210, height: 30, radius: 12),
            SizedBox(height: 14),
            StudentClassroomSkeletonBlock(height: 48, radius: 20),
            SizedBox(height: 14),
            _ClassroomSearchSkeleton(),
            SizedBox(height: 20),
            StudentClassroomSkeletonBlock(width: 170, height: 24, radius: 10),
            SizedBox(height: 12),
            StudentClassroomSkeletonBlock(height: 120, radius: 16),
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
          SizedBox(height: 8),
          StudentClassroomSkeletonBlock(height: 43, radius: 8),
          SizedBox(height: 14),
          StudentClassroomSkeletonBlock(width: 45, height: 18, radius: 8),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: StudentClassroomSkeletonBlock(height: 30, radius: 15)),
              SizedBox(width: 8),
              Expanded(child: StudentClassroomSkeletonBlock(height: 30, radius: 15)),
              SizedBox(width: 8),
              Expanded(child: StudentClassroomSkeletonBlock(height: 30, radius: 15)),
            ],
          ),
        ],
      ),
    );
  }
}