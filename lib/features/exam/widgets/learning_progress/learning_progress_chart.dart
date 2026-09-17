import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';

const _gradeColors = <Color>[
  Color(0xFFFF8B2C),
  Color(0xFFFA586C),
  Color(0xFFFFD534),
  Color(0xFF39B96B),
  Color(0xFF30B5F2),
  Color(0xFFA451E8),
];

class LearningProgressChart extends StatelessWidget {
  const LearningProgressChart({super.key, required this.points});
  final List<ExamProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final labels = List.generate(
      6,
      (grade) => grade == 0
          ? context.getText(AppKeys.gradeRoadmapKindergarten)
          : context.formatText(AppKeys.gradeRoadmapGrade, {'grade': grade}),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = labels
            .map((label) {
              final painter = TextPainter(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: Directionality.of(context),
              )..layout();
              return painter.width + 12;
            })
            .reduce(math.max);
        final height = (constraints.maxWidth * .66).clamp(250.0, 380.0);
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                height: height - 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final grade = 5 - index;
                    return Container(
                      width: labelWidth,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: _gradeColors[grade].withValues(alpha: .28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        labels[grade],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? _gradeColors[grade]
                              : Color.lerp(
                                  _gradeColors[grade],
                                  Colors.black,
                                  .4,
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, plotConstraints) {
                    final width = math.max(
                      plotConstraints.maxWidth,
                      points.length * 30.0,
                    );
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) => CustomPaint(
                          size: Size(width, height),
                          painter: LearningProgressChartPainter(
                            points: points,
                            testLabels: points
                                .map(
                                  (point) => context.formatText(
                                    AppKeys.learningProgressTestLabel,
                                    {'number': point.sequence},
                                  ),
                                )
                                .toList(growable: false),
                            progress: progress,
                            gridColor: colors.border,
                            textColor: colors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LearningProgressChartPainter extends CustomPainter {
  const LearningProgressChartPainter({
    required this.points,
    required this.testLabels,
    required this.progress,
    required this.gridColor,
    required this.textColor,
  });
  final List<ExamProgressPoint> points;
  final List<String> testLabels;
  final double progress;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const top = 11.0;
    final bottom = size.height - 28;
    final step = (bottom - top - 11) / 5;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = .8;
    for (var grade = 0; grade < 6; grade++) {
      final y = bottom - 11 - step * grade;
      for (var x = 1.0; x < size.width; x += 7) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 4, size.width), y),
          gridPaint,
        );
      }
    }
    final axisPaint = Paint()
      ..color = const Color(0xFFB1CED5)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(1, 0), Offset(1, bottom), axisPaint);
    canvas.drawLine(Offset(1, bottom), Offset(size.width, bottom), axisPaint);
    if (points.isEmpty) return;
    final slot = (size.width - 2) / points.length;
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final x = 2 + slot * (index + .5);
      final grade = point.grade;
      // Missing or unsupported grades must not be represented as kindergarten.
      if (grade != null && grade >= 0 && grade <= 5) {
        final barHeight = (11 + step * grade) * progress;
        final rect = Rect.fromLTRB(
          x - slot * .27,
          bottom - barHeight,
          x + slot * .27,
          bottom,
        );
        final color = _gradeColors[grade];
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.lerp(color, Colors.white, .12)!, color],
            ).createShader(rect),
        );
      } else {
        _text(canvas, '—', Offset(x, bottom - 12));
      }
      _text(canvas, testLabels[index], Offset(x, bottom + 16));
    }
  }

  void _text(Canvas canvas, String value, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant LearningProgressChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.testLabels != testLabels ||
      oldDelegate.progress != progress ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.textColor != textColor;
}
