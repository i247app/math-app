import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StudentInviteIconButton extends StatelessWidget {
  const StudentInviteIconButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, width: 25, height: 25),
      ),
    );
  }
}
