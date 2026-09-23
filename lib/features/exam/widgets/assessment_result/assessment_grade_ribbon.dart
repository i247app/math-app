import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_colors.dart';

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
            // The inverted-house tip stays centered over the active grade.
            SizedBox(
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: (targetCenterX - 14).clamp(0.0, totalWidth - 28),
                    width: 28,
                    height: 30,
                    child: Semantics(
                      label: context.getText(AppKeys.placementResultYouAreHere),
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
