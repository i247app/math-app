import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';

class AssessmentGradeRibbon extends StatelessWidget {
  const AssessmentGradeRibbon({super.key, required this.currentGrade});

  final int currentGrade;

  static const List<_GradeRibbonConfig> _grades = [
    _GradeRibbonConfig(
      bgColor: Color(0xFFB7EBF5),
      textColor: Color(0xFF04A8B3),
    ),
    _GradeRibbonConfig(
      bgColor: Color(0xFFB7EBF5),
      textColor: Color(0xFF17636D),
    ),
    _GradeRibbonConfig(
      bgColor: Color(0xFFC9E8D2),
      textColor: Color(0xFF205B35),
    ),
    _GradeRibbonConfig(
      bgColor: Color(0xFFFFF1BA),
      textColor: Color(0xFF6A5515),
    ),
    _GradeRibbonConfig(
      bgColor: Color(0xFFFFE1C4),
      textColor: Color(0xFF6E3F1A),
    ),
    _GradeRibbonConfig(
      bgColor: Color(0xFFFFD4C9),
      textColor: Color(0xFF6F2E27),
    ),
  ];
  // Text centers in grade-ribbon.png (the overlapping pills are not equal-width).
  static const List<double> _viGradeCenters = [
    0.087,
    0.263,
    0.408,
    0.557,
    0.707,
    0.858,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentGrade.clamp(0, _grades.length - 1);
    final isVietnamese = LingoScope.of(context).language == AppLanguage.vi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / _grades.length;
        final targetCenterX = isVietnamese
            ? totalWidth * _viGradeCenters[activeIndex]
            : segmentWidth * (activeIndex + 0.5);

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
              child: isVietnamese
                  ? Image.asset(
                      'assets/images/grade-ribbon.png',
                      width: totalWidth,
                      height: 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                    )
                  : _buildEnglishRibbon(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnglishRibbon(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / _grades.length;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              for (var index = _grades.length - 1; index >= 0; index--)
                Positioned(
                  left: index * segmentWidth,
                  top: 2,
                  width: segmentWidth + 12,
                  height: 36,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _grades[index].bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              for (var index = 0; index < _grades.length; index++)
                Positioned(
                  left: index * segmentWidth,
                  top: 0,
                  width: segmentWidth,
                  height: 40,
                  child: Center(
                    child: index == 0
                        ? Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFB5EBF4),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'K',
                              style: GoogleFonts.andika(
                                color: _grades[index].textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.formatText(
                                AppKeys.placementResultRibbonGrade,
                                {'grade': index},
                              ),
                              maxLines: 1,
                              style: GoogleFonts.andika(
                                color: _grades[index].textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GradeRibbonConfig {
  const _GradeRibbonConfig({required this.bgColor, required this.textColor});

  final Color bgColor;
  final Color textColor;
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
