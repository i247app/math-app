import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/sections/promo_actions/promo_action_data.dart';

class PromoActionCard extends StatelessWidget {
  const PromoActionCard({
    super.key,
    required this.data,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final PromoActionData data;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = data.image == null
        ? SizedBox.expand(child: data.child)
        : Ink.image(
            image: data.image!,
            fit: data.fit,
            alignment: data.alignment,
            child: const SizedBox.expand(),
          );

    return Semantics(
      button: true,
      label: data.semanticLabel,
      child: Material(
        color: data.backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: data.onTap, child: content),
      ),
    );
  }
}
