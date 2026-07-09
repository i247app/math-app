import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class ParentTaskTitle extends StatelessWidget {
  const ParentTaskTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
  }
}
