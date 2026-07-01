part of '../../review_tab.dart';

_ChapterCardColors _chapterColors(int number) {
  return switch (number) {
    1 => const _ChapterCardColors(
      background: Color(0xFFBFEFF4),
      shadow: Color(0xFF62C7D2),
    ),
    2 => const _ChapterCardColors(
      background: Color(0xFFD9F1DD),
      shadow: Color(0xFF8DD39C),
    ),
    3 => const _ChapterCardColors(
      background: Color(0xFFEADDF7),
      shadow: Color(0xFFBDA1DA),
    ),
    _ => const _ChapterCardColors(
      background: Color(0xFFFFF0B9),
      shadow: Color(0xFFE8C85A),
    ),
  };
}
