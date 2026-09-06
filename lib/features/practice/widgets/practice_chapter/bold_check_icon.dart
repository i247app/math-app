part of '../../screens/practice_chapter_screen.dart';

class _BoldCheckIcon extends StatelessWidget {
  const _BoldCheckIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BoldCheckPainter());
  }
}
