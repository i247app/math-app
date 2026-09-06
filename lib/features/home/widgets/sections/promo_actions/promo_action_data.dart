import 'package:flutter/material.dart';

class PromoActionData {
  const PromoActionData({
    required this.onTap,
    this.image,
    this.child,
    this.backgroundColor = Colors.transparent,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
  }) : assert(
         (image == null) != (child == null),
         'Provide exactly one of image or child.',
       );

  final VoidCallback onTap;
  final ImageProvider? image;
  final Widget? child;
  final Color backgroundColor;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticLabel;
}
