import 'package:flutter/material.dart';

class HomeHorizontalCarousel<T> extends StatelessWidget {
  const HomeHorizontalCarousel({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemWidth,
    required this.height,
    this.gap = 0,
    this.physics,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double itemWidth;
  final double height;
  final double gap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: gap),
        itemBuilder: (context, index) => SizedBox(
          width: itemWidth,
          child: itemBuilder(context, items[index]),
        ),
      ),
    );
  }
}
