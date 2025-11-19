import 'dart:ui';

class ClassItemData {
  final String title;
  final String imagePath;
  final Color color;
  final bool hasBadge;

  ClassItemData({
    required this.title,
    required this.imagePath,
    required this.color,
    this.hasBadge = false,
  });
}
