import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentHomeworkAttemptLoadingSkeleton extends StatefulWidget {
  const StudentHomeworkAttemptLoadingSkeleton({super.key, required this.scale});

  final double scale;

  @override
  State<StudentHomeworkAttemptLoadingSkeleton> createState() =>
      _StudentHomeworkAttemptLoadingSkeletonState();
}

class _StudentHomeworkAttemptLoadingSkeletonState
    extends State<StudentHomeworkAttemptLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return Padding(
          padding: EdgeInsets.fromLTRB(24 * s, 56 * s, 24 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeworkSkeletonBlock(
                progress: progress,
                height: 12 * s,
                borderRadius: 8 * s,
              ),
              SizedBox(height: 13 * s),
              _HomeworkSkeletonBlock(
                progress: progress,
                height: 8 * s,
                borderRadius: 6 * s,
              ),
              SizedBox(height: 32 * s),
              _HomeworkSkeletonBlock(
                progress: progress,
                height: 146 * s,
                borderRadius: 20 * s,
              ),
              SizedBox(height: 32 * s),
              for (var index = 0; index < 4; index++) ...[
                _HomeworkSkeletonBlock(
                  progress: progress,
                  height: 58 * s,
                  borderRadius: 14 * s,
                ),
                if (index != 3) SizedBox(height: 12 * s),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HomeworkSkeletonBlock extends StatelessWidget {
  const _HomeworkSkeletonBlock({
    required this.progress,
    required this.height,
    required this.borderRadius,
  });

  final double progress;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final highlightPosition = -1.4 + progress * 2.8;
    final base = colors.border.withValues(alpha: 0.5);
    final highlight = colors.elevatedSurface;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment(highlightPosition - 1, 0),
        end: Alignment(highlightPosition + 1, 0),
        colors: [base, highlight, base],
        stops: const [0.22, 0.5, 0.78],
      ).createShader(bounds),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: SizedBox(height: height),
      ),
    );
  }
}
