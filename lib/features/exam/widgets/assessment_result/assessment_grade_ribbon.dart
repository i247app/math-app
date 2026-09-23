import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';

class AssessmentGradeRibbon extends StatelessWidget {
  const AssessmentGradeRibbon({super.key, required this.currentGrade});

  final int currentGrade;

  // Text centers in the ribbon images (the overlapping pills are not equal-width).
  static const List<double> _viGradeCenters = [
    0.087,
    0.263,
    0.408,
    0.557,
    0.707,
    0.858,
  ];
  static const List<double> _enGradeCenters = [
    0.087,
    0.278,
    0.413,
    0.561,
    0.722,
    0.884,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentGrade.clamp(0, _viGradeCenters.length - 1);
    final isVietnamese = LingoScope.of(context).language == AppLanguage.vi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gradeCenters = isVietnamese ? _viGradeCenters : _enGradeCenters;
        final targetCenterX = totalWidth * gradeCenters[activeIndex];

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tooltip "Bạn đang ở" with down arrow pointing to currentGrade
            SizedBox(
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (targetCenterX - 56).clamp(0.0, totalWidth - 112),
                    width: 112,
                    child: Center(
                      child: _YouAreHereBadge(
                        text: context.getText(
                          AppKeys.placementResultYouAreHere,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              key: const ValueKey('placement-grade-ribbon'),
              height: 40,
              child: Image.asset(
                isVietnamese
                    ? 'assets/images/grade-ribbon.png'
                    : 'assets/images/grade-ribbon-en.png',
                width: totalWidth,
                height: 40,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _YouAreHereBadge extends StatelessWidget {
  const _YouAreHereBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('placement-you-are-here'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF38B6FF),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38B6FF).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            maxLines: 1,
            style: GoogleFonts.andika(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        // Downward pointing arrow triangle
        const CustomPaint(
          size: Size(10, 6),
          painter: _TrianglePointerPainter(color: Color(0xFF38B6FF)),
        ),
      ],
    );
  }
}

class _TrianglePointerPainter extends CustomPainter {
  const _TrianglePointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
