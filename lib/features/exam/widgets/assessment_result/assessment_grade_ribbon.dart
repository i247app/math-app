import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_colors.dart';

class AssessmentGradeRibbon extends StatelessWidget {
  const AssessmentGradeRibbon({super.key, required this.currentGrade});

  final int currentGrade;

  // Numeral centers in the shared ribbon (the overlapping pills are unequal).
  static const List<double> _gradeCenters = [
    0.093,
    0.272,
    0.414,
    0.562,
    0.719,
    0.884,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentGrade.clamp(0, _gradeCenters.length - 1);
    final gradeLabel = LingoScope.of(context).language == AppLanguage.vi
        ? 'LỚP'
        : 'GRADE';

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final targetCenterX = totalWidth * _gradeCenters[activeIndex];

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The inverted-house tip stays centered over the active grade.
            SizedBox(
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (targetCenterX - 26).clamp(0.0, totalWidth - 52),
                    width: 52,
                    child: Column(
                      children: [
                        Text(
                          gradeLabel,
                          key: const ValueKey('placement-current-grade-label'),
                          style: const TextStyle(
                            fontFamily: 'NunitoVariable',
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1,
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
                              key: ValueKey('placement-current-grade-marker'),
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
              key: const ValueKey('placement-grade-ribbon'),
              height: 40,
              child: Image.asset(
                'assets/images/grade-ribbon-numbers.png',
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
