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
  // Grade 1 follows the meadow bends between its fixed start and end points,
  // leaving room below the header and keeping the starting checkpoint visible.
  static const _roadCenters = <Offset>[
    Offset(318, 500),
    Offset(506.5, 1220),
    Offset(173, 1650),
    Offset(472, 2050),
    Offset(452, 2600),
    Offset(166, 2950),
    Offset(488, 3400),
    Offset(155, 3825),
    Offset(511.5, 4300),
    Offset(187.5, 4760),
  ];

  // Each background has its own road geometry in source-image coordinates.
  static const _kindergartenRoadCenters = <Offset>[
    Offset(557.5, 450),
    Offset(194.5, 928),
    Offset(645, 1406),
    Offset(196.5, 1883),
    Offset(687, 2361),
    Offset(188.5, 2839),
    Offset(699.5, 3317),
    Offset(249, 3794),
    Offset(586.5, 4272),
    Offset(414, 4750),
  ];

  // Place upper checkpoints on the autumn road's bends, just before the
  // outermost tips where needed to keep buttons inside narrow viewports.
  static const _grade2RoadCenters = <Offset>[
    Offset(412, 640),
    Offset(706, 1290),
    Offset(294.5, 1640),
    Offset(704.5, 1880),
    Offset(184.5, 2370),
    Offset(708, 2700),
    Offset(168, 3270),
    Offset(707, 3689),
    Offset(468, 4144),
    Offset(181, 4600),
  ];

  static const _grade3RoadCenters = <Offset>[
    Offset(599, 450),
    Offset(448, 900),
    Offset(410.5, 1350),
    Offset(458.5, 1800),
    Offset(374.5, 2250),
    Offset(565, 2700),
    Offset(161.5, 3150),
    Offset(620, 3600),
    Offset(639, 4050),
    Offset(224.5, 4500),
  ];

  // Follow the bends of the space road rather than uniform vertical intervals.
  static const _grade4RoadCenters = <Offset>[
    Offset(690.5, 750),
    Offset(637, 1520),
    Offset(241.5, 1850),
    Offset(649.5, 2150),
    Offset(174, 2525),
    Offset(696.5, 2920),
    Offset(193, 3350),
    Offset(689, 3800),
    Offset(186, 4250),
    Offset(584.5, 4750),
  ];

  // Grade 5 shares the meadow artwork with Grade 1, but uses its own bends
  // so adjusting these checkpoints does not move Grade 1's progression.
  static const _grade5RoadCenters = <Offset>[
    Offset(421.5, 600),
    Offset(506.5, 1220),
    Offset(173, 1650),
    Offset(472, 2050),
    Offset(452, 2600),
    Offset(166, 2950),
    Offset(488, 3400),
    Offset(155, 3825),
    Offset(511.5, 4300),
    Offset(177.5, 4800),
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
      5 => _grade5RoadCenters,
      _ => _roadCenters,
    };
    return centers[10 - level.clamp(1, 10)] *
        (width / imageSizeForGrade(grade).width);
  }
}
