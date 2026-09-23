import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

class AssessmentGradeRibbon extends StatelessWidget {
  const AssessmentGradeRibbon({super.key, required this.currentGrade});

  final int currentGrade;

  static const List<_GradeRibbonConfig> _grades = [
    _GradeRibbonConfig(
      label: 'K',
      bgColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF04A8B3),
      isCircleChip: true,
    ),
    _GradeRibbonConfig(
      label: 'Lớp 1',
      bgColor: Color(0xFFB7EBF5),
      textColor: Color(0xFF17636D),
    ),
    _GradeRibbonConfig(
      label: 'Lớp 2',
      bgColor: Color(0xFFC9E8D2),
      textColor: Color(0xFF205B35),
    ),
    _GradeRibbonConfig(
      label: 'Lớp 3',
      bgColor: Color(0xFFFFF1BA),
      textColor: Color(0xFF6A5515),
    ),
    _GradeRibbonConfig(
      label: 'Lớp 4',
      bgColor: Color(0xFFFFE1C4),
      textColor: Color(0xFF6E3F1A),
    ),
    _GradeRibbonConfig(
      label: 'Lớp 5',
      bgColor: Color(0xFFFFD4C9),
      textColor: Color(0xFF6F2E27),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentGrade.clamp(0, _grades.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / _grades.length;
        final targetCenterX = segmentWidth * (activeIndex + 0.5);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tooltip "Bạn đang ở" with down arrow pointing to currentGrade
            SizedBox(
              height: 38,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (targetCenterX - 56).clamp(0.0, totalWidth - 112),
                    child: _YouAreHereBadge(
                      text: context.getText(AppKeys.placementResultYouAreHere),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Ribbon bar
            Container(
              key: const ValueKey('placement-grade-ribbon'),
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: List.generate(_grades.length, (index) {
                    final config = _grades[index];
                    final label = index == 0
                        ? config.label
                        : context.formatText(
                            AppKeys.placementResultRibbonGrade,
                            {'grade': index},
                          );
                    final isSelected = index == activeIndex;

                    return Expanded(
                      child: Container(
                        height: 38,
                        color: config.bgColor,
                        alignment: Alignment.center,
                        child: config.isCircleChip
                            ? Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF04A8B3)
                                        : const Color(0xFFB5EBF4),
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF04A8B3,
                                      ).withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: GoogleFonts.andika(
                                    color: config.textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    style: GoogleFonts.andika(
                                      color: config.textColor,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GradeRibbonConfig {
  const _GradeRibbonConfig({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.isCircleChip = false,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isCircleChip;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF38B6FF),
            borderRadius: BorderRadius.circular(14),
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
              fontSize: 12,
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
