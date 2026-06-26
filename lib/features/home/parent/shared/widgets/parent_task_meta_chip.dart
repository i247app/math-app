part of '../../../home_screen.dart';

class _ParentTaskMetaChip extends StatelessWidget {
  const _ParentTaskMetaChip({
    required this.fontSize,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 82),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: FontSize.xxs,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
