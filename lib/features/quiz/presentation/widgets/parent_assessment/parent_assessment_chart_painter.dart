import 'package:numi/features/quiz/application/read_models/parent_assessment_read_model.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/application/read_models/parent_assessment_entry.dart';

class ParentAssessmentChartPainter extends CustomPainter {
  const ParentAssessmentChartPainter({required this.entries});

  final List<ParentAssessmentEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 22.0;
    const top = 10.0;
    final right = size.width - 5;
    final bottom = size.height - 18;
    final chartHeight = bottom - top;
    final chartWidth = right - left;
    final gridPaint = Paint()
      ..color = const Color(0xFFD7E5E4)
      ..strokeWidth = 0.7;

    for (var index = 0; index <= 5; index++) {
      final y = top + chartHeight * index / 5;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
      _paintText(
        canvas,
        '${10 - index * 2}',
        Offset(2, y - 5),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.54,
      );
    }

    if (entries.isEmpty) {
      return;
    }

    final points = <Offset>[];
    for (var index = 0; index < entries.length; index++) {
      final score = ((entries[index].quiz.grading?.scorePercentage ?? 0) / 10)
          .clamp(0, 10);
      final x = entries.length == 1
          ? left + chartWidth / 2
          : left + chartWidth * index / (entries.length - 1);
      final y = bottom - chartHeight * score / 10;
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, bottom)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFF85D7D2).withValues(alpha: 0.16),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF109B96)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final score = ((entries[index].quiz.grading?.scorePercentage ?? 0) / 10)
          .clamp(0, 10);
      canvas.drawCircle(point, 2.2, Paint()..color = const Color(0xFF007E79));
      _paintText(
        canvas,
        score.toStringAsFixed(1),
        Offset(point.dx - 6, point.dy - 12),
        color: const Color(0xFF007E79),
        fontSize: FontSize.caption * 0.5,
        fontWeight: FontWeight.w800,
      );
      final date = quizDate(entries[index].quiz).toLocal();
      final label = date.millisecondsSinceEpoch == 0
          ? '--/--'
          : '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}';
      _paintText(
        canvas,
        label,
        Offset(point.dx - 9, bottom + 5),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.5,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant ParentAssessmentChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
