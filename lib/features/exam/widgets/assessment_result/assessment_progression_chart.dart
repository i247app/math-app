import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

// The first test sits on the Y axis; the last keeps room for its halo.
const double _plotRightInset = 12;

double _pointX(int index, int count, double width) {
  if (count <= 1) return 0;
  return math.max(0, width - _plotRightInset) * index / (count - 1);
}

class AssessmentProgressionChart extends StatefulWidget {
  const AssessmentProgressionChart({
    super.key,
    required this.finalGrade,
    this.previousGrades = const <int>[],
    this.testNumbers,
    this.firstTestNumber = 1,
    this.maxVisiblePoints = 7,
    this.chartHeight = 150,
    this.lastSubmittedAt,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1400),
  }) : assert(maxVisiblePoints > 0);

  final int finalGrade;
  final List<int> previousGrades;
  final List<int>? testNumbers;
  final int firstTestNumber;
  final int maxVisiblePoints;
  final double chartHeight;
  final DateTime? lastSubmittedAt;
  final bool animate;
  final Duration animationDuration;

  @override
  State<AssessmentProgressionChart> createState() =>
      _AssessmentProgressionChartState();
}

class _AssessmentProgressionChartState extends State<AssessmentProgressionChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AssessmentProgressionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _controller.value = 1;
      return;
    }
    if (!oldWidget.animate ||
        oldWidget.finalGrade != widget.finalGrade ||
        !listEquals(oldWidget.previousGrades, widget.previousGrades) ||
        !listEquals(oldWidget.testNumbers, widget.testNumbers) ||
        oldWidget.firstTestNumber != widget.firstTestNumber ||
        oldWidget.maxVisiblePoints != widget.maxVisiblePoints) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _resolvePoints(int visibleCount) {
    final historyLimit = visibleCount - 1;
    final history = widget.previousGrades.length > historyLimit
        ? widget.previousGrades.sublist(
            widget.previousGrades.length - historyLimit,
          )
        : widget.previousGrades;
    return [
      ...history.map((grade) => grade.clamp(0, 5).toDouble()),
      widget.finalGrade.clamp(0, 5).toDouble(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final grade = widget.finalGrade.clamp(0, 5);
    final activityLabel = context.getText(AppKeys.placementResultActivity);
    final gradeDescription = context.getText(AppKeys.placementResultChartGrade);
    return LayoutBuilder(
      builder: (context, constraints) {
        // A narrow card leaves less space after the grade and vertical axis.
        final visibleCount = math.min(
          widget.maxVisiblePoints,
          constraints.maxWidth < 330 ? 6 : 7,
        );
        final points = _resolvePoints(visibleCount);
        final chartHeight = constraints.hasBoundedHeight
            ? math.min(
                widget.chartHeight,
                math.max(60.0, constraints.maxHeight - 90.0),
              )
            : widget.chartHeight;
        final axisRowHeight = math.min(24.0, chartHeight / 6);
        return Container(
          key: const ValueKey('placement-progression-chart'),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD8E6EA)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const _StairsIcon(),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 79,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        gradeDescription,
                        key: const ValueKey(
                          'placement-progression-grade-title',
                        ),
                        style: GoogleFonts.andika(
                          color: const Color(0xFF1C3A43),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          activityLabel,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF61747B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 115,
                    child: Padding(
                      // Keep the number centered under the grade title.
                      padding: const EdgeInsets.only(left: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 79,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                '$grade',
                                key: const ValueKey(
                                  'placement-progression-current-grade',
                                ),
                                style: GoogleFonts.andika(
                                  color: const Color(0xFF1C3A43),
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          // Reserve the old caption's height so the number
                          // keeps its vertical position when the caption hides.
                          SizedBox(
                            height: math.min(
                              30.0,
                              math.max(0.0, chartHeight - 74.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SizedBox(
                      height: chartHeight,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 29,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var value = 5; value >= 0; value--)
                                  SizedBox(
                                    height: axisRowHeight,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              value == 0 ? 'K' : '$value',
                                              key: ValueKey(
                                                'placement-progression-axis-label-$value',
                                              ),
                                              style: GoogleFonts.andika(
                                                color: const Color(0xFF61747B),
                                                fontSize: math.min(
                                                  14.0,
                                                  axisRowHeight * 0.7,
                                                ),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          key: ValueKey(
                                            'placement-progression-tick-$value',
                                          ),
                                          width: 4,
                                          height: math.min(
                                            12.0,
                                            axisRowHeight * 0.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _levelColor(value),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => CustomPaint(
                                key: const ValueKey(
                                  'placement-progression-plot',
                                ),
                                painter: _AssessmentChartPainter(
                                  points: points,
                                  progress: _animation.value,
                                  axisInset: axisRowHeight / 2,
                                ),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _levelColor(int value) => switch (value) {
  5 => const Color(0xFFD75A4C),
  4 => const Color(0xFFE18B30),
  3 => const Color(0xFFD1AE31),
  2 => const Color(0xFF48A05D),
  1 => const Color(0xFF22A3A9),
  _ => const Color(0xFF279BC0),
};

class _StairsIcon extends StatelessWidget {
  const _StairsIcon();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(24, 24), painter: _StairsPainter());
}

class _StairsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D9CC2)
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(1, 22)
        ..lineTo(6, 22)
        ..lineTo(6, 15)
        ..lineTo(12, 15)
        ..lineTo(12, 8)
        ..lineTo(18, 8)
        ..lineTo(18, 2)
        ..lineTo(23, 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StairsPainter oldDelegate) => false;
}

class _AssessmentChartPainter extends CustomPainter {
  const _AssessmentChartPainter({
    required this.points,
    required this.progress,
    required this.axisInset,
  });

  final List<double> points;
  final double progress;
  final double axisInset;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5ECEE)
      ..strokeWidth = 1;
    final plotHeight = math.max(0.0, size.height - 2 * axisInset);
    double yForGrade(double grade) => axisInset + plotHeight * (1 - grade / 5);
    for (var grade = 0; grade <= 5; grade++) {
      final y = yForGrade(grade.toDouble());
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    if (points.isEmpty) return;

    Offset position(int index) => Offset(
      _pointX(index, points.length, size.width),
      yForGrade(points[index].clamp(0, 5)),
    );
    final offsets = [for (var i = 0; i < points.length; i++) position(i)];
    final reveal = progress.clamp(0.0, 1.0);
    final linePaint = Paint()
      ..color = const Color(0xFF93AEB2)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < offsets.length; i++) {
      final endpoint = i == offsets.length - 1
          ? Offset.lerp(offsets[i - 1], offsets[i], reveal)!
          : offsets[i];
      canvas.drawLine(offsets[i - 1], endpoint, linePaint);
    }

    void drawDot(Offset center, Color border, {bool finalPoint = false}) {
      if (finalPoint) {
        canvas.drawCircle(
          center,
          math.min(20.0 / 3, axisInset),
          Paint()..color = const Color(0xFFD9EED5),
        );
      }
      canvas.drawCircle(center, 10.0 / 3, Paint()..color = Colors.white);
      canvas.drawCircle(
        center,
        10.0 / 3,
        Paint()
          ..color = border
          ..strokeWidth = 2.2 * 2 / 3
          ..style = PaintingStyle.stroke,
      );
    }

    for (var i = 0; i < offsets.length - 1; i++) {
      drawDot(offsets[i], const Color(0xFF2496AB));
    }
    if (offsets.length == 1 || reveal >= 1) {
      drawDot(offsets.last, const Color(0xFF3A9B44), finalPoint: true);
    } else if (reveal > 0) {
      drawDot(
        Offset.lerp(offsets[offsets.length - 2], offsets.last, reveal)!,
        const Color(0xFF3A9B44),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AssessmentChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.axisInset != axisInset ||
      !listEquals(oldDelegate.points, points);
}
