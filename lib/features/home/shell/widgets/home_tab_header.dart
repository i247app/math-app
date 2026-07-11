import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/page_header.dart';

class HomeTabHeader extends StatelessWidget {
  const HomeTabHeader({
    super.key,
    required this.title,
    required this.scale,
    this.topInset,
  });

  final String title;
  final double scale;
  final double? topInset;

  @override
  Widget build(BuildContext context) {
    return PageHeader(title: title, scale: scale, topInset: topInset);
  }
}
