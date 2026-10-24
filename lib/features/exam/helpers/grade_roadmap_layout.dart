import 'package:flutter/painting.dart';

class GradeRoadmapLayout {
  const GradeRoadmapLayout._();

  static const backgroundAsset = 'assets/images/grade-roadmap-background.jpg';
  static const imageWidth = 672.0;
  static const imageHeight = 4988.0;
  static const kindergartenBackgroundAsset =
      'assets/images/grade-roadmap-background-k.png';
  static const grade2BackgroundAsset =
      'assets/images/grade-roadmap-background-2.png';
  static const grade3BackgroundAsset =
      'assets/images/grade-roadmap-background-3.png';
  static const grade4BackgroundAsset =
      'assets/images/grade-roadmap-background-4.png';

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
  static const _kindergartenRoadCenters = <Offset>[
    Offset(193, 880),
    Offset(587, 1310),
    Offset(338, 1740),
    Offset(458, 2170),
    Offset(502, 2600),
    Offset(310, 3030),
    Offset(688, 3460),
    Offset(195, 3890),
    Offset(640, 4320),
    Offset(414, 4750),
  ];

  static const _grade2RoadCenters = <Offset>[
    Offset(418.5, 1000),
    Offset(707, 1400),
    Offset(557.5, 1800),
    Offset(382.5, 2200),
    Offset(539, 2600),
    Offset(522, 3000),
    Offset(302.5, 3400),
    Offset(703, 3800),
    Offset(417, 4200),
    Offset(181, 4600),
  ];

  static const _grade3RoadCenters = <Offset>[
    Offset(449, 900),
    Offset(343.5, 1300),
    Offset(593, 1700),
    Offset(210.5, 2100),
    Offset(643, 2500),
    Offset(274.5, 2900),
    Offset(260.5, 3300),
    Offset(672, 3700),
    Offset(610.5, 4100),
    Offset(224.5, 4500),
  ];

  static const _grade4RoadCenters = <Offset>[
    Offset(593, 900),
    Offset(443, 1300),
    Offset(427.5, 1700),
    Offset(639, 2100),
    Offset(176, 2500),
    Offset(695.5, 2900),
    Offset(203, 3300),
    Offset(663.5, 3700),
    Offset(305.5, 4100),
    Offset(451, 4500),
  ];

  static String backgroundAssetForGrade(int grade) => switch (grade) {
    0 => kindergartenBackgroundAsset,
    2 => grade2BackgroundAsset,
    3 => grade3BackgroundAsset,
    4 => grade4BackgroundAsset,
    _ => backgroundAsset,
  };

  static Size imageSizeForGrade(int grade) => switch (grade) {
    0 => const Size(863, 4948),
    2 => const Size(863, 4917),
    3 => const Size(861, 4951),
    4 => const Size(863, 4942),
    _ => const Size(imageWidth, imageHeight),
  };

  static double heightForWidth(double width, {int grade = 0}) {
    final size = imageSizeForGrade(grade);
    return width * size.height / size.width;
  }

  static Offset centerForLevel(int level, double width, {int grade = 0}) {
    final centers = switch (grade) {
      0 => _kindergartenRoadCenters,
      2 => _grade2RoadCenters,
      3 => _grade3RoadCenters,
      4 => _grade4RoadCenters,
      _ => _roadCenters,
    };
    return centers[10 - level.clamp(1, 10)] *
        (width / imageSizeForGrade(grade).width);
  }
}
