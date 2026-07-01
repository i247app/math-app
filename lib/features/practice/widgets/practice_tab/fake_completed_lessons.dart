part of '../../practice_tab.dart';

int _fakeCompletedLessons(int chapterNumber, int lessonCount) {
  if (lessonCount <= 0) {
    return 0;
  }
  return switch (chapterNumber) {
    1 => lessonCount,
    2 => (lessonCount * 0.38).round().clamp(1, lessonCount),
    _ => 0,
  };
}
