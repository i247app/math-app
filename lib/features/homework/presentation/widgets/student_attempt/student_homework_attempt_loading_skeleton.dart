import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentHomeworkAttemptLoadingSkeleton extends StatefulWidget {
  const StudentHomeworkAttemptLoadingSkeleton({super.key});

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _HomeworkSkeletonBlock(
                  progress: progress,
                  height: 12,
                  borderRadius: 8,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _HomeworkSkeletonBlock(
                  progress: progress,
                  height: 8,
                  borderRadius: 6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _HomeworkSkeletonBlock(
                  progress: progress,
                  height: 146,
                  borderRadius: 20,
                ),
              ),
              Column(
                spacing: 12,
                children: List.generate(
                  4,
                  (_) => _HomeworkSkeletonBlock(
                    progress: progress,
                    height: 58,
                    borderRadius: 14,
                  ),
                ),
              ),
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
