import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentTaskDateLabel extends StatelessWidget {
  const ParentTaskDateLabel({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.alarm_rounded,
          color: Colors.black87,
          size: FontSize.xxs,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: FontSize.xxs,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
