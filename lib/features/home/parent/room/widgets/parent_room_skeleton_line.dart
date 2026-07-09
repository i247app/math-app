import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentRoomSkeletonLine extends StatelessWidget {
  const ParentRoomSkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: 22,
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFEE),
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }
}