import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';

class GradeExamLevelRibbon extends StatelessWidget {
  const GradeExamLevelRibbon({super.key, required this.currentLevel});

  final int currentLevel;

  // Centers measured from the numerals in grade-ribbon-levels-1-10.png.
  static const List<double> _levelCenters = [
    0.0734,
    0.1973,
    0.2834,
    0.3715,
    0.4586,
    0.5483,
    0.6409,
    0.7318,
    0.8218,
    0.9180,
  ];

  @override
  Widget build(BuildContext context) {
    final activeLevel = currentLevel.clamp(1, _levelCenters.length);
    final levelLabel = context
        .getText(AppKeys.placementResultChartGrade)
        .toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final targetCenterX = width * _levelCenters[activeLevel - 1];

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: targetCenterX - 21),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, left, child) =>
                        Positioned(left: left, width: 42, child: child!),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 42,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              levelLabel,
                              key: const ValueKey(
                                'grade-exam-current-level-label',
                              ),
                              style: GoogleFonts.nunito(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 28,
                          height: 30,
                          child: Semantics(
                            label: context.getText(
                              AppKeys.placementResultYouAreHere,
                            ),
                            child: const ClipPath(
                              key: ValueKey('grade-exam-current-level-marker'),
                              clipper: _InvertedHouseClipper(),
                              child: ColoredBox(color: AppColors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              key: const ValueKey('grade-exam-level-ribbon'),
              height: 40,
              child: Image.asset(
                'assets/images/grade-ribbon-levels-1-10.png',
                width: width,
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

class _InvertedHouseClipper extends CustomClipper<Path> {
  const _InvertedHouseClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(3, 0)
      ..lineTo(size.width - 3, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 3)
      ..lineTo(size.width, size.height * 0.53)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.53)
      ..lineTo(0, 3)
      ..quadraticBezierTo(0, 0, 3, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _InvertedHouseClipper oldClipper) => false;
}
