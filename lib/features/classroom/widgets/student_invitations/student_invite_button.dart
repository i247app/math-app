import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentInviteButton extends StatelessWidget {
  const StudentInviteButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: FilledButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
