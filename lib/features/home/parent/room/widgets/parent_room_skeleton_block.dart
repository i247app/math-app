import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParentRoomSkeletonBlock extends StatelessWidget {
  const ParentRoomSkeletonBlock({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EFEE),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}