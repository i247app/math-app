import 'package:flutter/painting.dart';

class GradeRoadmapLayout {
  const GradeRoadmapLayout._();

  static const backgroundAsset = 'assets/images/grade-roadmap-background.jpg';
  static const imageWidth = 672.0;
  static const imageHeight = 4988.0;
  static const grade2BackgroundAsset =
      'assets/images/grade-roadmap-background-2.png';

  // Road-center coordinates in the source image, ordered from Level 10 to 1.
  static const _roadCenters = <Offset>[
    Offset(363, 1016),
    Offset(360.5, 1432),
    Offset(296.5, 1848),
    Offset(313, 2264),
    Offset(403, 2680),
    Offset(232, 3096),
    Offset(437, 3512),
    Offset(193, 3928),
    Offset(510.5, 4344),
    Offset(187.5, 4760),
  ];

  // Each background has its own road geometry in source-image coordinates.
  static const _grade2RoadCenters = <Offset>[
    Offset(419, 880),
    Offset(390, 1310),
    Offset(397, 1740),
    Offset(310.5, 2170),
    Offset(535.5, 2600),
    Offset(191.5, 3030),
    Offset(574, 3460),
    Offset(214, 3890),
    Offset(641.5, 4320),
    Offset(203.5, 4750),
  ];

  static String backgroundAssetForGrade(int grade) =>
      grade == 2 ? grade2BackgroundAsset : backgroundAsset;

  static Size imageSizeForGrade(int grade) =>
      grade == 2 ? const Size(863, 4945) : const Size(imageWidth, imageHeight);

  static double heightForWidth(double width, {int grade = 0}) {
    final size = imageSizeForGrade(grade);
    return width * size.height / size.width;
  }

  static Offset centerForLevel(int level, double width, {int grade = 0}) {
    final centers = grade == 2 ? _grade2RoadCenters : _roadCenters;
    return centers[10 - level.clamp(1, 10)] *
        (width / imageSizeForGrade(grade).width);
  }
}
