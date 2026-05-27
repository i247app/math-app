import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/practice_catalog.dart';

const _pathBackground = Color(0xFFF0E4FF);
const _pathPurple = Color(0xFFA64DF3);
const _pathInk = Color(0xFF14213D);
const _pathMuted = Color(0xFF8A94A5);
const _coinYellow = Color(0xFFFFC928);
const _headerNavy = Color(0xFF063A7B);
const _headerLine = Color(0xFFDE8C4B);

class PracticeChapterScreen extends StatefulWidget {
  const PracticeChapterScreen({
    super.key,
    required this.chapter,
  });

  final PracticeChapter chapter;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final context = _lessonKeys[_currentIndex].currentContext;
      if (context == null) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        alignment: 0.50,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pathBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth, 430.0);
            final scale = width / PracticeChapterScreen._designWidth;

            return Center(
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    _ChapterHeader(chapter: widget.chapter, scale: scale),
                    Expanded(
                      child: _LessonPath(
                        chapter: widget.chapter,
                        lessonKeys: _lessonKeys,
                        scrollController: _scrollController,
                        mascotAnimation: _mascotController,
                        currentIndex: _currentIndex,
                        onLayoutReady: _scheduleScrollToCurrent,
                        scale: scale,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                      color: const Color(0xFF00776F),
                      size: 24 * scale,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Chương ${chapter.number}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _headerNavy,
                    fontFamily: 'Nunito',
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
    required this.scale,
  });

  final PracticeChapter chapter;
  final List<GlobalKey> lessonKeys;
  final ScrollController scrollController;
  final Animation<double> mascotAnimation;
  final int currentIndex;
  final VoidCallback onLayoutReady;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final contentHeight =
        math.max(720.0 * scale, (chapter.lessons.length * 150 + 220) * scale);

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      reverse: true,
      padding: EdgeInsets.only(bottom: 34 * scale),
      child: SizedBox(
        height: contentHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final points =
                _nodePoints(width, contentHeight, chapter.lessons.length);
            final mascotPoint =
                points[currentIndex.clamp(0, points.length - 1)];
            final mascotOnLeft = mascotPoint.dx > width * 0.55;
            final mascotLeft = mascotOnLeft
                ? mascotPoint.dx - 132 * scale
                : mascotPoint.dx + 28 * scale;
            final mascotTop = mascotPoint.dy - 78 * scale;
            onLayoutReady();

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DottedPathPainter(points: points, scale: scale),
                  ),
                ),
                Positioned(
                  right: 35 * scale,
                  top: 104 * scale,
                  child: _FloatingGlyph(
                    icon: Icons.star_rounded,
                    color: const Color(0xFFFFD000),
                    scale: scale,
                  ),
                ),
                Positioned(
                  left: 48 * scale,
                  top: 250 * scale,
                  child: _FloatingGlyph(
                    icon: Icons.music_note_rounded,
                    color: const Color(0xFF52646D),
                    scale: scale,
                  ),
                ),
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
                    left: points[index].dx - 66 * scale,
                    top: points[index].dy - 48 * scale,
                    child: _LessonNode(
                      key: lessonKeys[index],
                      lesson: chapter.lessons[index],
                      index: index,
                      chapter: chapter,
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
    required this.scale,
  });

  final PracticeLesson lesson;
  final int index;
  final PracticeChapter chapter;
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
    final nodeColor = _completed
        ? const Color(0xFF88C87A)
        : _current
            ? _pathPurple
            : const Color(0xFFE5E9EE);
    final foreground = _locked ? _pathMuted : Colors.white;
    final showGo = _current;
    return GestureDetector(
      onTap: () {
        if (_locked) {
          HapticFeedback.selectionClick();
          return;
        }

        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bài ${lesson.number}: ${lesson.title} sẽ mở sau.'),
          ),
        );
      },
      child: SizedBox(
        width: 132 * scale,
        child: Column(
          children: [
            if (showGo)
              Container(
                margin: EdgeInsets.only(bottom: 6 * scale),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 5 * scale,
                ),
                decoration: BoxDecoration(
                  color: _coinYellow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Text(
                  'GO!',
                  style: TextStyle(
                    color: _pathInk,
                    fontFamily: 'Nunito',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 0,
                    offset: Offset(0, 8 * scale),
                  ),
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.24),
                    blurRadius: 26 * scale,
                    offset: Offset(0, 14 * scale),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _locked
                  ? Icon(Icons.lock_rounded,
                      color: foreground, size: 22 * scale)
                  : Text(
                      '${lesson.number}',
                      maxLines: 1,
                      style: TextStyle(
                        color: foreground,
                        fontFamily: 'Nunito',
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _locked ? _pathMuted : const Color(0xFF6B1FC8),
                fontFamily: 'Nunito',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingGlyph extends StatelessWidget {
  const _FloatingGlyph({
    required this.icon,
    required this.color,
    required this.scale,
  });

  final IconData icon;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: 28 * scale);
  }
}

class _DottedPathPainter extends CustomPainter {
  const _DottedPathPainter({
    required this.points,
    required this.scale,
  });

  final List<Offset> points;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFC993F4).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * scale
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final yDirection = end.dy >= start.dy ? 1.0 : -1.0;
      final controlA = Offset(start.dx, start.dy + 48 * scale * yDirection);
      final controlB = Offset(end.dx, end.dy - 48 * scale * yDirection);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
            controlA.dx, controlA.dy, controlB.dx, controlB.dy, end.dx, end.dy);
      _drawDashedPath(canvas, path, paint, 22 * scale, 17 * scale);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double gapLength,
  ) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.scale != scale;
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
