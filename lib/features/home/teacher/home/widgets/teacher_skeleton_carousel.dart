import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_horizontal_carousel.dart';

class TeacherSkeletonCarousel extends StatelessWidget {
  const TeacherSkeletonCarousel({
    super.key,
    required this.scale,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemCount,
    required this.builder,
  });

  final double scale;
  final double itemWidth;
  final double itemHeight;
  final int itemCount;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return HomeHorizontalCarousel<int>(
      items: List<int>.generate(itemCount, (index) => index),
      itemWidth: itemWidth,
      height: itemHeight,
      gap: 16 * scale,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, _) => builder(context),
    );
  }
}
