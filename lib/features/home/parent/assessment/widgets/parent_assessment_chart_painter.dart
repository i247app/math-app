part of '../../../home_screen.dart';

class _ParentAssessmentChartPainter extends CustomPainter {
  const _ParentAssessmentChartPainter({
    required this.entries,
    required this.scale,
  });

  final List<_ParentAssessmentEntry> entries;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 22 * scale;
    final top = 10 * scale;
    final right = size.width - 5 * scale;
    final bottom = size.height - 18 * scale;
    final chartHeight = bottom - top;
    final chartWidth = right - left;
    final gridPaint = Paint()
      ..color = const Color(0xFFD7E5E4)
      ..strokeWidth = 0.7 * scale;

    for (var index = 0; index <= 5; index++) {
      final y = top + chartHeight * index / 5;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
      _paintText(
        canvas,
        '${10 - index * 2}',
        Offset(2 * scale, y - 5 * scale),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.54 * scale,
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
        ..strokeWidth = 1.4 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final score = ((entries[index].quiz.grading?.scorePercentage ?? 0) / 10)
          .clamp(0, 10);
      canvas.drawCircle(
        point,
        2.2 * scale,
        Paint()..color = const Color(0xFF007E79),
      );
      _paintText(
        canvas,
        score.toStringAsFixed(1),
        Offset(point.dx - 6 * scale, point.dy - 12 * scale),
        color: const Color(0xFF007E79),
        fontSize: FontSize.caption * 0.5 * scale,
        fontWeight: FontWeight.w800,
      );
      final date = _quizDate(entries[index].quiz).toLocal();
      final label = date.millisecondsSinceEpoch == 0
          ? '--/--'
          : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}';
      _paintText(
        canvas,
        label,
        Offset(point.dx - 9 * scale, bottom + 5 * scale),
        color: const Color(0xFF5A676A),
        fontSize: FontSize.caption * 0.5 * scale,
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
  bool shouldRepaint(covariant _ParentAssessmentChartPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.scale != scale;
  }
}
