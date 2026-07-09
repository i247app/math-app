import 'package:flutter/material.dart';

class StudentClassroomSkeletonBlock extends StatelessWidget {
  const StudentClassroomSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    required this.radius,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}