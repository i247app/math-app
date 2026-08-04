import 'package:flutter/material.dart';

class PromoActionGroup extends StatelessWidget {
  const PromoActionGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.spacing = 10,
  });

  final List<Widget> children;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    assert(
      children.isNotEmpty && children.length <= 2,
      'PromoActionGroup accepts one or two children.',
    );
    return Flex(
      direction: direction,
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final child in children) Expanded(child: child)],
    );
  }
}
