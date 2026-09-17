import 'package:flutter/material.dart';

class HomeBannerData {
  const HomeBannerData({
    required this.image,
    required this.onTap,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final ImageProvider image;
  final VoidCallback onTap;
  final Alignment alignment;
  final BoxFit fit;
  final String? semanticLabel;
}
