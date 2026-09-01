import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherMemberSectionTitle extends StatelessWidget {
  const TeacherMemberSectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF1E3A5F),
        fontSize: FontSize.large,
        fontWeight: FontWeight.w700,
        height: 1.55,
      ),
    );
  }
}
