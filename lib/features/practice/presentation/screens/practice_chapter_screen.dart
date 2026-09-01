import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/practice/domain/models/practice_catalog.dart';

part '../widgets/practice_chapter/learning_path_header.dart';
part '../widgets/practice_chapter/chapter_header.dart';
part '../widgets/practice_chapter/chapter_header_curve_painter.dart';
part '../widgets/practice_chapter/lesson_path.dart';
part '../widgets/practice_chapter/numi_mascot.dart';
part '../widgets/practice_chapter/lesson_node.dart';
part '../widgets/practice_chapter/current_lesson_bubble.dart';
part '../widgets/practice_chapter/bubble_arrow_painter.dart';
part '../widgets/practice_chapter/level_button.dart';
part '../widgets/practice_chapter/bold_check_icon.dart';
part '../widgets/practice_chapter/bold_check_painter.dart';
part '../widgets/practice_chapter/completed_lesson_dialog.dart';
part '../widgets/practice_chapter/node_points.dart';

const _pathBackground = Color(0xFFFBFDFE);
const _pathBlue = Color(0xFF1CB0F6);
const _pathBlueShadow = Color(0xFF168AC0);
const _headerTeal = Color(0xFF38898B);
const _headerTealShadow = Color(0xFF286E70);
const _completedGold = Color(0xFFF5B400);
const _completedGoldShadow = Color(0xFFC78300);
const _reviewGreen = Color(0xFF58CC02);
const _reviewGreenShadow = Color(0xFF46A302);
const _pathMuted = Color(0xFF8A94A5);
const _headerNavy = Color(0xFF063A7B);
const _headerLine = Color(0xFFDE8C4B);

class PracticeChapterScreen extends StatefulWidget {
  const PracticeChapterScreen({
    super.key,
    required this.chapter,
    this.embedded = false,
    this.bottomPadding = 0,
    this.onLessonTap,
    this.onEmbeddedBack,
    this.showEmbeddedChapterLabel = true,
  });

  final PracticeChapter chapter;
  final bool embedded;
  final double bottomPadding;
  final ValueChanged<PracticeLesson>? onLessonTap;
  final VoidCallback? onEmbeddedBack;
  final bool showEmbeddedChapterLabel;

  static const _designWidth = 390.0;

  @override
  State<PracticeChapterScreen> createState() => _PracticeChapterScreenState();
}

class _PracticeChapterScreenState extends State<PracticeChapterScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final AnimationController _mascotController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat(reverse: true);
  late final List<GlobalKey> _lessonKeys = List.generate(
    widget.chapter.lessons.length,
    (_) => GlobalKey(),
  );
  bool _didScrollToCurrent = false;

  @override
  void dispose() {
    _mascotController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _currentIndex {
    if (widget.chapter.isLocked) {
      return 0;
    }
    if (widget.chapter.completedLessons >= widget.chapter.lessons.length) {
      return widget.chapter.lessons.length - 1;
    }
    return widget.chapter.completedLessons.clamp(
      0,
      widget.chapter.lessons.length - 1,
    );
  }

  void _scheduleScrollToCurrent() {
    if (_didScrollToCurrent || _lessonKeys.isEmpty) {
      return;
    }
    _didScrollToCurrent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) {
        return;
      }
      final context = _lessonKeys[_currentIndex].currentContext;
      if (context == null || !context.mounted) {
        return;
      }
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        alignment: 0.50,
      );
    });
  }

  Future<void> _showCompletedLessonReview(PracticeLesson lesson) async {
    HapticFeedback.lightImpact();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) => _CompletedLessonDialog(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 430.0);
        final scale = width / PracticeChapterScreen._designWidth;

        return Center(
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                if (widget.embedded)
                  _LearningPathHeader(
                    chapter: widget.chapter,
                    lesson: widget.chapter.lessons[_currentIndex],
                    scale: scale,
                    onBack: widget.onEmbeddedBack,
                    showChapterLabel: widget.showEmbeddedChapterLabel,
                  )
                else
                  _ChapterHeader(chapter: widget.chapter, scale: scale),
                Expanded(
                  child: _LessonPath(
                    chapter: widget.chapter,
                    lessonKeys: _lessonKeys,
                    scrollController: _scrollController,
                    mascotAnimation: _mascotController,
                    currentIndex: _currentIndex,
                    onLayoutReady: _scheduleScrollToCurrent,
                    onCompletedLessonTap: _showCompletedLessonReview,
                    onLessonTap: widget.onLessonTap,
                    bottomPadding: widget.bottomPadding,
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.embedded) {
      return ColoredBox(
        color: context.themeColors.pageBackground,
        child: SafeArea(bottom: false, child: content),
      );
    }

    return Scaffold(
      backgroundColor: context.themeColors.pageBackground,
      body: SafeArea(bottom: false, child: content),
    );
  }
}
