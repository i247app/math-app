part of '../../practice_tab.dart';

List<PracticeChapter> _practiceChaptersFromApi(List<ChapterModel> chapters) {
  final sorted = [...chapters]
    ..sort((a, b) {
      final left = a.displayOrder ?? 0;
      final right = b.displayOrder ?? 0;
      if (left != right) {
        return left.compareTo(right);
      }
      return _chapterLabel(a).compareTo(_chapterLabel(b));
    });

  return List.generate(sorted.length, (index) {
    final chapter = sorted[index];
    final number = index + 1;
    final lessonCount =
        chapter.lessonCount ??
        _fallbackPracticeChapter(number)?.lessonCount ??
        0;

    return PracticeChapter(
      id: _practiceChapterId(chapter),
      number: number,
      title: _chapterDescription(chapter) ?? _chapterLabel(chapter),
      description: _chapterLabel(chapter),
      lessons: const <PracticeLesson>[],
      lessonCountOverride: lessonCount,
      completedLessons: _estimatedCompletedLessons(number, lessonCount),
      icon: _chapterIcon(number),
    );
  });
}
