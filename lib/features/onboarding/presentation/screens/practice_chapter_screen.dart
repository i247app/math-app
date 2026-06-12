import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../data/practice_catalog.dart';

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
  });

  final PracticeChapter chapter;
  final bool embedded;
  final double bottomPadding;

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
        color: _pathBackground,
        child: SafeArea(
          bottom: false,
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pathBackground,
      body: SafeArea(
        bottom: false,
        child: content,
      ),
    );
  }
}

class _LearningPathHeader extends StatelessWidget {
  const _LearningPathHeader({
    required this.chapter,
    required this.lesson,
    required this.scale,
  });

  final PracticeChapter chapter;
  final PracticeLesson lesson;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        12 * scale,
        18 * scale,
        10 * scale,
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: 104 * scale),
        decoration: BoxDecoration(
          color: _headerTeal,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: _headerTealShadow,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22 * scale,
                  16 * scale,
                  14 * scale,
                  16 * scale,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.formatText(
                        AppKeys.learningPathChapterLesson,
                        {
                          'chapter': chapter.number,
                          'lesson': lesson.number,
                        },
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: Colors.white,
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 72 * scale,
              constraints: BoxConstraints(minHeight: 104 * scale),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: _headerTealShadow.withValues(alpha: 0.7),
                    width: 2 * scale,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.format_list_numbered_rounded,
                color: Colors.white,
                size: 32 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.chapter,
    required this.scale,
  });

  final PracticeChapter chapter;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70 * scale,
      child: CustomPaint(
        painter: _ChapterHeaderCurvePainter(scale: scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            8 * scale,
            20 * scale,
            12 * scale,
          ),
          child: Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.80),
                shadowColor: Colors.black.withValues(alpha: 0.05),
                elevation: 1,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                  },
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44 * scale,
                    height: 44 * scale,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _headerNavy,
                      size: 24 * scale,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  context.formatText(
                    AppKeys.chapterNumber,
                    {'number': chapter.number},
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headerNavy,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(width: 44 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterHeaderCurvePainter extends CustomPainter {
  const _ChapterHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _pathBackground;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = _headerLine.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;
    final path = Path()
      ..moveTo(0, size.height - 6 * scale)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 6 * scale,
        size.width,
        size.height - 6 * scale,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ChapterHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}

class _LessonPath extends StatelessWidget {
  const _LessonPath({
    required this.chapter,
    required this.lessonKeys,
    required this.scrollController,
    required this.mascotAnimation,
    required this.currentIndex,
    required this.onLayoutReady,
    required this.onCompletedLessonTap,
    required this.bottomPadding,
    required this.scale,
  });

  final PracticeChapter chapter;
  final List<GlobalKey> lessonKeys;
  final ScrollController scrollController;
  final Animation<double> mascotAnimation;
  final int currentIndex;
  final VoidCallback onLayoutReady;
  final ValueChanged<PracticeLesson> onCompletedLessonTap;
  final double bottomPadding;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final contentHeight =
        math.max(720.0 * scale, (chapter.lessons.length * 138 + 190) * scale);

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      padding: EdgeInsets.only(bottom: bottomPadding + 34 * scale),
      child: SizedBox(
        height: contentHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final points =
                _nodePoints(width, contentHeight, chapter.lessons.length);
            final mascotIndex = math.min(
              currentIndex + 2,
              chapter.lessons.length - 1,
            );
            final mascotPoint = points[mascotIndex];
            final mascotOnLeft = mascotPoint.dx > width * 0.55;
            final mascotLeft = mascotOnLeft
                ? mascotPoint.dx - 142 * scale
                : mascotPoint.dx + 38 * scale;
            final mascotTop = mascotPoint.dy - 48 * scale;
            onLayoutReady();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: mascotLeft.clamp(8 * scale, width - 100 * scale),
                  top: mascotTop.clamp(24 * scale, contentHeight - 130 * scale),
                  child: _NumiMascot(
                    animation: mascotAnimation,
                    scale: scale,
                  ),
                ),
                for (var index = 0; index < chapter.lessons.length; index++)
                  Positioned(
                    left: points[index].dx - 110 * scale,
                    top: points[index].dy - 103 * scale,
                    child: _LessonNode(
                      key: lessonKeys[index],
                      lesson: chapter.lessons[index],
                      index: index,
                      chapter: chapter,
                      onCompletedTap: onCompletedLessonTap,
                      scale: scale,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NumiMascot extends StatelessWidget {
  const _NumiMascot({
    required this.animation,
    required this.scale,
  });

  final Animation<double> animation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final lift = math.sin(animation.value * math.pi) * -10 * scale;
        final tilt = math.sin(animation.value * math.pi * 2) * 0.035;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.rotate(
            angle: tilt,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: 96 * scale,
        height: 96 * scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 5 * scale,
              child: Container(
                width: 58 * scale,
                height: 12 * scale,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Image.asset(
              'assets/images/welcome_numi_character.png',
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    super.key,
    required this.lesson,
    required this.index,
    required this.chapter,
    required this.onCompletedTap,
    required this.scale,
  });

  final PracticeLesson lesson;
  final int index;
  final PracticeChapter chapter;
  final ValueChanged<PracticeLesson> onCompletedTap;
  final double scale;

  bool get _completed => index < chapter.completedLessons;

  bool get _current {
    if (chapter.isLocked) {
      return false;
    }
    if (chapter.completedLessons >= chapter.lessons.length) {
      return index == chapter.lessons.length - 1;
    }
    return index == chapter.completedLessons;
  }

  bool get _locked {
    if (chapter.isLocked) {
      return true;
    }
    if (chapter.completedLessons >= chapter.lessons.length) {
      return false;
    }
    return index > chapter.completedLessons;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220 * scale,
      height: 150 * scale,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          if (_current)
            Positioned(
              top: 0,
              left: 5 * scale,
              right: 5 * scale,
              child: _CurrentLessonBubble(
                title: lesson.title,
                scale: scale,
              ),
            ),
          Positioned(
            top: 64 * scale,
            child: GestureDetector(
              onTap: () {
                if (_completed) {
                  onCompletedTap(lesson);
                  return;
                }
                HapticFeedback.selectionClick();
              },
              child: _LevelButton(
                completed: _completed,
                current: _current,
                locked: _locked,
                scale: scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentLessonBubble extends StatelessWidget {
  const _CurrentLessonBubble({
    required this.title,
    required this.scale,
  });

  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 48 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 8 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13 * scale),
            border: Border.all(
              color: const Color(0xFFE2E6E9),
              width: 2 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _pathBlue,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.08,
            ),
          ),
        ),
        CustomPaint(
          size: Size(16 * scale, 9 * scale),
          painter: const _BubbleArrowPainter(),
        ),
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  const _BubbleArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) => false;
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.completed,
    required this.current,
    required this.locked,
    required this.scale,
  });

  final bool completed;
  final bool current;
  final bool locked;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? _completedGold
        : current
            ? _pathBlue
            : const Color(0xFFE5E8EB);
    final shadow = completed
        ? _completedGoldShadow
        : current
            ? _pathBlueShadow
            : const Color(0xFFBEC3C7);

    return Container(
      width: 82 * scale,
      height: 82 * scale,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: completed
          ? _BoldCheckIcon(size: 42 * scale)
          : Icon(
              current ? Icons.star_rounded : Icons.lock_rounded,
              color: locked ? _pathMuted : Colors.white,
              size: 34 * scale,
              weight: 900,
            ),
    );
  }
}

class _BoldCheckIcon extends StatelessWidget {
  const _BoldCheckIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BoldCheckPainter(),
    );
  }
}

class _BoldCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.76)
      ..lineTo(size.width * 0.84, size.height * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoldCheckPainter oldDelegate) => false;
}

class _CompletedLessonDialog extends StatelessWidget {
  const _CompletedLessonDialog({required this.lesson});

  final PracticeLesson lesson;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 40, 390.0);
    final scale = width / PracticeChapterScreen._designWidth;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(22 * scale),
        decoration: BoxDecoration(
          color: _reviewGreen,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: _reviewGreenShadow,
              offset: Offset(0, 7 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lesson.title,
              style: GoogleFonts.andika(
                color: Colors.white,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              context.getText(AppKeys.improveMathTypePrompt),
              style: GoogleFonts.andika(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            SizedBox(height: 22 * scale),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14 * scale),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(14 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15 * scale),
                  child: Text(
                    context.getText(AppKeys.reviewLessonAction).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.andika(
                      color: _reviewGreen,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Offset> _nodePoints(double width, double height, int count) {
  const top = 90.0;
  final spacing = (height - 160) / math.max(count, 1);
  final center = width / 2;
  final amplitude = math.min(width * 0.28, 112.0);

  return List.generate(count, (index) {
    final y = height - top - spacing * index;
    final x = center + math.sin(index * 1.35) * amplitude;
    return Offset(x, y);
  });
}
