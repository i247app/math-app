part of '../../review_tab.dart';

PracticeChapter? _fallbackPracticeChapter(int number) {
  for (final chapter in gradeOnePracticeChapters) {
    if (chapter.number == number) {
      return chapter;
    }
  }
  return null;
}
