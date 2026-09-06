import 'package:flutter/material.dart';

class GuideItemData {
  const GuideItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.semanticLabel,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? semanticLabel;
}
