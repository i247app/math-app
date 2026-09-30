import 'package:flutter/painting.dart';

class GradeRoadmapLayout {
  const GradeRoadmapLayout._();

  static const backgroundAsset = 'assets/images/grade-roadmap-background.jpg';
  static const imageWidth = 672.0;
  static const imageHeight = 4988.0;

  // Road-center coordinates in the source image, ordered from Level 10 to 0.
  static const _roadCenters = <Offset>[
    Offset(424.5, 600),
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

  static double heightForWidth(double width) =>
      width * imageHeight / imageWidth;

  static Offset centerForLevel(int level, double width) =>
      _roadCenters[10 - level.clamp(0, 10)] * (width / imageWidth);
}
