part of '../../screens/practice_chapter_screen.dart';

List<Offset> _nodePoints(double width, double height, int count) {
  const top = 90.0;
  final spacing = (height - 160) / math.max(count, 1);
  final center = width / 2;
  final amplitude = math.min(width * 0.28, 112.0);

  return List.generate(count, (index) {
    final y = height - top - spacing * index;
    final x = center + math.sin(index * 1.35) * amplitude;
    return Offset(x, y);
  });
}
