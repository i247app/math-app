import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class AssessmentProgressionChart extends StatefulWidget {
  const AssessmentProgressionChart({
    super.key,
    required this.finalGrade,
    this.previousGrades = const <int>[],
    this.firstTestNumber = 1,
    this.chartHeight = 150.0,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1400),
  });

  final int finalGrade;
  final List<int> previousGrades;
  final int firstTestNumber;
  final double chartHeight;
  final bool animate;
  final Duration animationDuration;

  static const List<_YAxisGradeConfig> _yGrades = [
    _YAxisGradeConfig(barColor: Color(0xFFFF8A80), level: 5),
    _YAxisGradeConfig(barColor: Color(0xFFFFA726), level: 4),
    _YAxisGradeConfig(barColor: Color(0xFFFFD54F), level: 3),
    _YAxisGradeConfig(barColor: Color(0xFF81C784), level: 2),
    _YAxisGradeConfig(barColor: Color(0xFF4DD0E1), level: 1),
    _YAxisGradeConfig(barColor: Color(0xFF26C6DA), level: 0),
  ];

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
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AssessmentProgressionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.animate) {
      _controller.value = 1.0;
      return;
    }

    final dataChanged =
        oldWidget.finalGrade != widget.finalGrade ||
        !listEquals(oldWidget.previousGrades, widget.previousGrades) ||
        oldWidget.firstTestNumber != widget.firstTestNumber;
    if (!oldWidget.animate || dataChanged) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _resolvePoints() {
    final target = widget.finalGrade.clamp(0, 5).toDouble();
    final history = widget.previousGrades.length > 4
        ? widget.previousGrades.sublist(widget.previousGrades.length - 4)
        : widget.previousGrades;
    return <double>[
      ...history.map((grade) => grade.clamp(0, 5).toDouble()),
      target,
    ];
  }

  String _gradeLabel(BuildContext context, int grade) {
    if (grade <= 0) {
      return context.getText(AppKeys.placementResultKindergartenShort);
    }
    return context.formatText(AppKeys.placementResultRibbonGrade, {
      'grade': grade,
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = _resolvePoints();
    final pointCount = points.length;

    return Container(
      key: const ValueKey('placement-progression-chart'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 18, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main chart row: Y-axis on left + Canvas on right
          SizedBox(
            height: widget.chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-Axis labels
                SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: AssessmentProgressionChart._yGrades.map((config) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                config.level == 0
                                    ? context.getText(
                                        AppKeys
                                            .placementResultKindergartenShort,
                                      )
                                    : context.formatText(
                                        AppKeys.placementResultRibbonGrade,
                                        {'grade': config.level},
                                      ),
                                style: GoogleFonts.andika(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            width: 3,
                            height: 10,
                            decoration: BoxDecoration(
                              color: config.barColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                // Plot canvas
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final progress = _animation.value;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: _AssessmentChartPainter(
                                  points: points,
                                  yGradeCount: AssessmentProgressionChart
                                      ._yGrades
                                      .length,
                                  animationProgress: progress,
                                ),
                              ),
                              // Jump origin badge (if transitioning between different grades)
                              if (points.length >= 2)
                                _buildPreviousPointBadge(
                                  constraints: constraints,
                                  points: points,
                                  label: _gradeLabel(
                                    context,
                                    points[points.length - 2].round(),
                                  ),
                                  progress: progress,
                                ),
                              // Floating badge for final point
                              _buildFinalPointBadge(
                                constraints: constraints,
                                points: points,
                                label: _gradeLabel(context, widget.finalGrade),
                                progress: progress,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // X-Axis labels row aligned with canvas
          Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Row(
                  children: List.generate(pointCount, (index) {
                    return Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            context.formatText(AppKeys.placementResultTest, {
                              'number': widget.firstTestNumber + index,
                            }),
                            style: GoogleFonts.andika(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousPointBadge({
    required BoxConstraints constraints,
    required List<double> points,
    required String label,
    required double progress,
  }) {
    if (points.length < 2) return const SizedBox.shrink();
    final prevIndex = points.length - 2;
    final prevVal = points[prevIndex];
    final height = constraints.maxHeight;
    final width = constraints.maxWidth;

    final prevX = width * (prevIndex / (points.length - 1));
    final prevY = height - (prevVal / 5.0) * height;

    final badgeProgress = ((progress - 0.55) / 0.25).clamp(0.0, 1.0);
    if (badgeProgress <= 0) return const SizedBox.shrink();

    final scale = Curves.easeOutBack.transform(badgeProgress);

    return Positioned(
      left: (prevX - 22).clamp(0.0, width - 44),
      top: (prevY - 24).clamp(0.0, height - 20),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: badgeProgress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.andika(
                color: const Color(0xFF4B5563),
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalPointBadge({
    required BoxConstraints constraints,
    required List<double> points,
    required String label,
    required double progress,
  }) {
    if (points.isEmpty) return const SizedBox.shrink();
    final lastPoint = points.last;
    final height = constraints.maxHeight;
    const yLevels = 5.0; // 0..5
    final lastY = height - (lastPoint / yLevels) * height;

    final badgeProgress = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
    if (badgeProgress <= 0) return const SizedBox.shrink();

    final scale = Curves.easeOutBack.transform(badgeProgress);

    return Positioned(
      right: 0,
      top: (lastY - 26).clamp(0.0, height - 24),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: badgeProgress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.andika(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YAxisGradeConfig {
  const _YAxisGradeConfig({required this.barColor, required this.level});

  final Color barColor;
  final int level;
}

class _AssessmentChartPainter extends CustomPainter {
  const _AssessmentChartPainter({
    required this.points,
    required this.yGradeCount,
    required this.animationProgress,
  });

  final List<double> points;
  final int yGradeCount;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. Draw horizontal gridlines and Y-axis line
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F2F5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final yAxisPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Y-axis vertical line at x = 0
    canvas.drawLine(const Offset(0, 0), Offset(0, height), yAxisPaint);

    final levels = yGradeCount - 1; // 5 levels between 6 labels
    for (var i = 0; i <= levels; i++) {
      final y = height * (i / levels);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    if (points.isEmpty) return;

    // 2. Map the four most recent completed assessments and the new result.
    final count = points.length;
    final offsets = <Offset>[];
    for (var i = 0; i < count; i++) {
      final x = count == 1 ? width : width * (i / (count - 1));
      final val = points[i].clamp(0.0, 5.0);
      final y = height - (val / 5.0) * height;
      offsets.add(Offset(x, y));
    }

    final progress = animationProgress.clamp(0.0, 1.0);
    final lastSegmentIndex = count - 2;
    final segmentProgress = count > 1 ? progress : 1.0;
    final segmentStart = count > 1 ? offsets[lastSegmentIndex] : offsets.last;
    final currentHead = count > 1
        ? Offset.lerp(segmentStart, offsets.last, segmentProgress)!
        : offsets.last;
    final currentVal = count > 1
        ? points[lastSegmentIndex] +
              (points.last - points[lastSegmentIndex]) * segmentProgress
        : points.last;

    // Keep every historical segment visible; only the final segment animates.
    if (count > 1) {
      final areaPath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (var i = 1; i < count - 1; i++) {
        areaPath.lineTo(offsets[i].dx, offsets[i].dy);
      }
      areaPath
        ..lineTo(currentHead.dx, currentHead.dy)
        ..lineTo(currentHead.dx, height)
        ..lineTo(offsets.first.dx, height)
        ..close();

      final areaShader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x3500B4D8), // Cyan
          Color(0x3526A69A), // Teal
          Color(0x3566BB6A), // Green
          Color(0x45FDD835), // Yellow
          Color(0x50FFA726), // Orange
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

      final areaPaint = Paint()
        ..shader = areaShader
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // 3. Draw historical segments followed by the animated new segment.
    for (var i = 0; i < count - 1; i++) {
      final isNewSegment = i == lastSegmentIndex;
      if (isNewSegment && segmentProgress <= 0) continue;

      final startPt = offsets[i];
      final endPt = isNewSegment ? currentHead : offsets[i + 1];
      final color1 = _colorForValue(points[i]);
      final color2 = _colorForValue(isNewSegment ? currentVal : points[i + 1]);
      final linePaint = Paint()
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (color1 == color2 || (endPt - startPt).distance < 1.0) {
        linePaint.color = color1;
      } else {
        linePaint.shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color1, color2],
        ).createShader(Rect.fromPoints(startPt, endPt));
      }
      canvas.drawLine(startPt, endPt, linePaint);
    }

    // Draw all completed assessment points; reveal the new point at the end.
    for (var i = 0; i < count - 1; i++) {
      _drawHistoricalPoint(canvas, offsets[i], _colorForValue(points[i]));
    }
    if (count == 1 || progress >= 1.0) {
      final pointColor = _colorForValue(points.last);
      final haloRadius = count == 1
          ? 10.0
          : 10.0 *
                Curves.easeOutBack.transform(
                  ((progress - 0.9) / 0.1).clamp(0.0, 1.0),
                );
      canvas.drawCircle(
        offsets.last,
        haloRadius,
        Paint()..color = pointColor.withValues(alpha: 0.25),
      );
      canvas.drawCircle(offsets.last, 5.5, Paint()..color = pointColor);
      canvas.drawCircle(offsets.last, 2.5, Paint()..color = Colors.white);
    }

    // Moving pen is restricted to the final segment between the latest tests.
    if (count > 1 && progress > 0.02 && progress < 0.99) {
      final penColor = _colorForValue(currentVal);

      // Outer glow pulse
      final glowPaint = Paint()
        ..color = penColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentHead, 9.0, glowPaint);

      // Main pen bead
      final penPaint = Paint()
        ..color = penColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentHead, 5.0, penPaint);

      // Inner white sparkle
      final innerSparkle = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentHead, 2.2, innerSparkle);
    }
  }

  Color _colorForValue(double val) {
    if (val <= 0.8) return const Color(0xFF00B4D8); // Cyan
    if (val <= 1.8) return const Color(0xFF00ACC1); // Teal
    if (val <= 2.8) return const Color(0xFF43A047); // Green
    if (val <= 3.8) return const Color(0xFFFFB300); // Yellow/Amber
    return const Color(0xFFFFA726); // Orange
  }

  void _drawHistoricalPoint(Canvas canvas, Offset point, Color color) {
    canvas.drawCircle(point, 4.5, Paint()..color = color);
    canvas.drawCircle(
      point,
      4.5,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _AssessmentChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.yGradeCount != yGradeCount ||
        oldDelegate.animationProgress != animationProgress;
  }
}
