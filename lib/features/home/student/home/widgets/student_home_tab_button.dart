import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/constants/home_visual_constants.dart';

class StudentHomeTabButton extends StatelessWidget {
  const StudentHomeTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20 * scale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 42 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Colors.white : homeMuted,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
