import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';

class LearningProgressChart extends StatelessWidget {
  const LearningProgressChart({super.key, required this.points});

  final List<QuizProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white87 : AppColors.black87;
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(
          constraints.maxWidth,
          54.0 + math.max(0, points.length - 1) * 54,
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return CustomPaint(
                size: Size(chartWidth, 350),
                painter: LearningProgressChartPainter(
                  points: points,
                  progress: progress,
                  lineColor: AppColors.brandTeal,
                  pointColor: AppColors.brandTealSolid,
                  fillColor: AppColors.brandTeal.withValues(alpha: 0.12),
                  gridColor: colors.border,
                  textColor: textColor,
                  mutedTextColor: colors.textMuted,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class LearningProgressChartPainter extends CustomPainter {
  const LearningProgressChartPainter({
    required this.points,
    required this.progress,
    required this.lineColor,
    required this.pointColor,
    required this.fillColor,
    required this.gridColor,
    required this.textColor,
    required this.mutedTextColor,
  });

  final List<QuizProgressPoint> points;
  final double progress;
  final Color lineColor;
  final Color pointColor;
  final Color fillColor;
  final Color gridColor;
  final Color textColor;
  final Color mutedTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const rightInset = 20.0;
    const top = 30.0;
    const bottomInset = 46.0;
    final right = size.width - rightInset;
    final bottom = size.height - bottomInset;
    final chartWidth = right - left;
    final chartHeight = bottom - top;

    for (var value = 0; value <= 10; value++) {
      final y = bottom - chartHeight * value / 10;
      _drawDashedLine(
        canvas,
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = gridColor.withValues(alpha: value == 0 ? 0.9 : 0.65)
          ..strokeWidth = value == 0 ? 1 : 0.8,
      );
      _paintText(
        canvas,
        '$value',
        Offset(left - 16, y),
        color: mutedTextColor,
        fontSize: FontSize.xxxs,
        alignment: Alignment.center,
      );
    }

    if (points.isEmpty) {
      return;
    }

    final spacing = points.length == 1 ? 0.0 : chartWidth / (points.length - 1);
    final chartPoints = <Offset>[
      for (var index = 0; index < points.length; index++)
        Offset(
          points.length == 1 ? left + chartWidth / 2 : left + spacing * index,
          bottom -
              chartHeight *
                  (_score(points[index]) / 10).clamp(0.0, 1.0) *
                  progress,
        ),
    ];

    final fillPath = Path()
      ..moveTo(chartPoints.first.dx, bottom)
      ..lineTo(chartPoints.first.dx, chartPoints.first.dy);
    for (final point in chartPoints.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(chartPoints.last.dx, bottom)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    if (chartPoints.length > 1) {
      final linePath = Path()
        ..moveTo(chartPoints.first.dx, chartPoints.first.dy);
      for (final point in chartPoints.skip(1)) {
        linePath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var index = 0; index < chartPoints.length; index++) {
      final point = chartPoints[index];
      final score = _score(points[index]);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = lineColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
      _paintText(
        canvas,
        _scoreLabel(score),
        Offset(point.dx, point.dy - 17),
        color: textColor,
        fontSize: FontSize.xxs,
        fontWeight: FontWeight.w800,
        alignment: Alignment.center,
      );

      final date = points[index].completedDt.toLocal();
      final dateLabel =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}';
      _paintText(
        canvas,
        dateLabel,
        Offset(point.dx, bottom + 26),
        color: textColor,
        fontSize: FontSize.xxxs,
        fontWeight: FontWeight.w700,
        alignment: Alignment.center,
      );
    }
  }

  double _score(QuizProgressPoint point) => point.score.clamp(0, 10);

  String _scoreLabel(double score) {
    return score == score.roundToDouble()
        ? score.toInt().toString()
        : score.toStringAsFixed(1);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(
        Offset(x, start.dy),
        Offset(math.min(x + dashWidth, end.dx), end.dy),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Alignment alignment = Alignment.topLeft,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(
      anchor.dx - (alignment.x + 1) * painter.width / 2,
      anchor.dy - (alignment.y + 1) * painter.height / 2,
    );
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant LearningProgressChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.mutedTextColor != mutedTextColor;
  }
}
