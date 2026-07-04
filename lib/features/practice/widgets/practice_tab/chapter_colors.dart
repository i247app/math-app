part of '../../practice_tab.dart';

PracticeChapterCardColors _chapterColors(int number) {
  return switch (number) {
    1 => const PracticeChapterCardColors(
      background: Color(0xFFBFEFF4),
      shadow: Color(0xFF62C7D2),
    ),
    2 => const PracticeChapterCardColors(
      background: Color(0xFFD9F1DD),
      shadow: Color(0xFF8DD39C),
    ),
    3 => const PracticeChapterCardColors(
      background: Color(0xFFEADDF7),
      shadow: Color(0xFFBDA1DA),
    ),
    _ => const PracticeChapterCardColors(
      background: Color(0xFFFFF0B9),
      shadow: Color(0xFFE8C85A),
    ),
  };
}
