import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/promo_actions/promo_action_group.dart';

class PromoActionsSection extends StatelessWidget {
  const PromoActionsSection({
    super.key,
    required this.children,
    this.height = defaultHeight,
    this.spacing = 10,
  });

  static const double defaultHeight = 160;

  final List<Widget> children;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    assert(
      children.isNotEmpty && children.length <= 2,
      'PromoActionsSection accepts one or two columns.',
    );
    return SizedBox(
      height: height,
      child: PromoActionGroup(spacing: spacing, children: children),
    );
  }
}
