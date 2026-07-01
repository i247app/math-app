part of '../../review_tab.dart';

class _SelectCircle extends StatelessWidget {
  const _SelectCircle({required this.selected, required this.scale});

  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34 * scale,
      height: 34 * scale,
      decoration: BoxDecoration(
        color: selected ? _checkPink : Colors.transparent,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(color: _uncheckedCircle, width: 2.4 * scale),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: Colors.white, size: 25 * scale)
          : null,
    );
  }
}
