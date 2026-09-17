import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherClassDetailMetaRow extends StatelessWidget {
  const TeacherClassDetailMetaRow({
    super.key,
    required this.iconAsset,
    required this.text,
  });
  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        spacing: 10,
        children: [
          Image.asset(
            iconAsset,
            width: 18,
            height: 18,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF001741),
                fontSize: FontSize.small,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
